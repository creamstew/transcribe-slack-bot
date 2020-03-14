require 'aws-sdk-s3'
require 'json'
require 'slack-ruby-client'

def post_slack(event:, context:)
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    objkey = event['Records'][0]['s3']['object']['key']
    s3_client = Aws::S3::Client.new(region: ENV['REGION'])
    json_file = s3_client.get_object(bucket: bucket_name, key: objkey).body.read
    hash = JSON.parse(json_file)
    transcribe_txt = hash['results']['transcripts'][0]['transcript'].gsub(/\s/, "")

    Slack.configure do |config|
        config.token = ENV['SLACK_OAUTH_TOKEN']
    end
    slack_client = Slack::Web::Client.new
    slack_client.files_upload(
        channels: ENV['SLACK_CHANNEL'],
        as_user: true,
        file: Faraday::UploadIO.new(StringIO.new(transcribe_txt), 'text/plain'),
        filename: 'transcribe.txt'
      )
end