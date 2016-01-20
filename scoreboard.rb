require 'octokit'
require 'ostruct'
require 'dotenv'
Dotenv.load

# Scoreboard downloads a github repos statistics
class Scoreboard
  def initialize
    @client = Octokit::Client.new \
      client_id: ENV['GH_CLIENT_ID'],
      client_secret: ENV['GH_CLIENT_SECRET']
    @users = []
    @stats = client.contributors_stats(ENV['GH_REPO'])
  end

  def grab_statistics
    @stats.each do |stat|
      user = OpenStruct.new(stat[:author].to_hash)
      user.total_commits = stat[:total]
      user.weeks = stat[:weeks]
      @users << user
    end
  end
end
