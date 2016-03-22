require 'dropbox_sdk'
require 'pp'

def access_token
  if ENV.key? 'DROPBOX_ACCESS_TOKEN'
    return ENV['DROPBOX_ACCESS_TOKEN'
  else
    raise 'Need token in DROPBOX_ACCESS_TOKEN environment variable'
  end
end

puts '--- Connecting to Dropbox ---'
client = DropboxClient.new(access_token)

puts '--- Uploading Files ---'
# Dir['_output/*.pdf'].each do |pdf|
file = open('_output/junk.pdf')
response = client.put_file("/Testing/junk.pdf", file)
pp "  uploaded:", response.inspect
# end
