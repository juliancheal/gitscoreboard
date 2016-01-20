require 'octokit'
require 'ostruct'
require 'dotenv'
require './storage'
Dotenv.load

# Scoreboard downloads a github repos statistics
class Scoreboard
  def initialize
    @client = Octokit::Client.new \
      client_id: ENV['GH_CLIENT_ID'],
      client_secret: ENV['GH_CLIENT_SECRET']
    @users = []
    @stats = @client.contributors_stats(ENV['GH_REPO'])
    @storage = Storage.new
  end

  def grab_statistics
    @stats.each do |stat|
      user = OpenStruct.new(stat[:author].to_hash)
      user.total_commits = stat[:total]
      user.weeks = stat[:weeks]
      @users << user
    end
  end

  def create_users
    @users.each do |user|
      puts "Creating storage for #{user.login}"
      @storage.create_folder('users', user.login)
    end
  end

  def create_weeks
    uniq_weeks.each do |week|
      time_at = Time.at(week)
      date = "#{time_at.year}/#{time_at.month}/#{time_at.day}"
      puts "Creating storage for #{date}"
      @storage.create_folder('weeks', date)
    end
  end

  def store_users
    @users.each do |user|
      data = {}
      data[:username] = user.login
      data[:avatar_url] = user.avatar_url
      data[:total_commits] = user.total_commits
      @storage.store_data("users/#{user.login}", user.login, data)
    end
  end

  # Go through the users
  # Grab their weekly data
  # place in file per day by name
  # number of: Additions, Deletions, Commits
  def store_weeks
    @users.each do |user|
      user.weeks.each do |week|
        time_at = Time.at(week.w)
        date = "#{time_at.year}/#{time_at.month}/#{time_at.day}"
        data = {}
        data[:username] = user.login
        data[:week] = week.w
        data[:additions] = week.a
        data[:deletions] = week.d
        data[:commits] = week.c
        @storage.store_data("weeks/#{date}", user.login, data)
      end
    end
  end

  private

  def uniq_weeks
    uniq_weeks = []
    @users.each do |user|
      user.weeks.each do |week|
        uniq_weeks << week.w
      end
    end
    uniq_weeks.uniq
  end
end

scoreboard = Scoreboard.new
scoreboard.grab_statistics
scoreboard.create_users
scoreboard.create_weeks
scoreboard.store_users
scoreboard.store_weeks
