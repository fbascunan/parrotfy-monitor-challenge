# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before reading this file.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Set output log for debugging
set :output, "log/cron.log"

# Set environment variables for cron
env :PATH, ENV['PATH']
env :GEM_HOME, ENV['GEM_HOME']
env :GEM_PATH, ENV['GEM_PATH']
env :RBENV_ROOT, ENV['RBENV_ROOT']
env :RBENV_VERSION, ENV['RBENV_VERSION']

# Set the job_type to use the full path
job_type :rails_runner, "cd :path && :environment_variable=:environment bundle exec rails runner ':task' :output"

# Set environment to development
set :environment, 'development'

# Run roulette rounds every 3 minutes
every 3.minutes do
  rails_runner "PlayRouletteRoundJob.perform_later"
end

# Reset all player balances to $10,000 daily at midnight
every 1.day, at: '12:00 am' do
  rails_runner "Player.update_all(balance: 10000.0)"
end
