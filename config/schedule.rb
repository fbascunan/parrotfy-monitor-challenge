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

# Run roulette rounds every 3 minutes
every 3.minutes do
  runner "PlayRouletteRoundJob.perform_later"
end

# Reset all player balances to $10,000 daily at midnight
every 1.day, at: '12:00 am' do
  runner "Player.update_all(balance: 10000.0)"
end
