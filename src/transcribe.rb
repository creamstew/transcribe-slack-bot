require 'aws-sdk-s3'
require 'aws-sdk-transcribeservice'
require 'json'

def start_job(event:, context:)
  input_bucket = event['Records'][0]['s3']['bucket']['name']
  output_bucket = ENV['OUTPUT_BACKET']
  objkey = event['Records'][0]['s3']['object']['key']
  file_path = 'https://s3-' + ENV['REGION'] + '.amazonaws.com/' + input_bucket + '/' + objkey
  file_type = File.extname(objkey).delete('.')
  job_name = context.aws_request_id

  if ['flac','wav','mp3','mp4'].include?(file_type)
    client = Aws::TranscribeService::Client.new(region: ENV['REGION'])
    params = {
      language_code: 'ja-JP',
      media: {
        media_file_uri: file_path
      },
      transcription_job_name: job_name,
      media_format: file_type,
      output_bucket_name: output_bucket
    }
    client.start_transcription_job(params)
  end
end