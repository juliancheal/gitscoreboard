require 'dotenv'
Dotenv.load

client = Octokit::Client.new \
  client_id: ENV['GH_CLIENT_ID'],
  client_secret: ENV['GH_CLIENT_SECRET']
