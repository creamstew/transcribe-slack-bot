require 'aws-sdk-s3'
require 'json'
require 'open-uri'

def put_s3(event:, context:)
    hash = JSON.parse(event['body'])
    case hash['type']
    when 'url_verification'
        res = { challenge: hash['challenge'] }
        { statusCode: 200, body: JSON.generate(res) }
    when 'event_callback'
        if hash['event']['files'].nil?
            return { statusCode: 200 }
        elsif ['flac','wav','mp3','mp4'].include?(hash['event']['files'][0]['filetype'])
            file_url = hash['event']['files'][0]['url_private_download']
            file_name = hash['event']['files'][0]['name']
            output_file_path = '/tmp/'+ file_name
            open(output_file_path, 'wb') { |saved_file|
                open(file_url,
                     'Authorization' => 'Bearer ' + ENV['SLACK_OAUTH_TOKEN'],
                     ) { |read_file|
                  saved_file.write(read_file.read)
                }
            }
            s3 = Aws::S3::Resource.new(region: ENV['REGION'])
            obj = s3.bucket(ENV['INPUT_BACKET']).object(file_name)
            obj.upload_file(output_file_path)
        end
    end
    { statusCode: 200 }
end