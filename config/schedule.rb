# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
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

# clean cron: crontab -r
# update cron: whenever: whenever --update-crontab
# update cron: whenever development: whenever --update-crontab --set environment=development


env :PATH, '/home/toko/.local/share/mise/installs/ruby/3.4.4/bin:/usr/local/bin:/usr/bin:/bin'
set :output, './log/cron.log'

every 1.minutes do
  runner 'puts Time.now'
  runner 'puts Rails.env'
  runner "puts 'Hello, world'"
  runner 'Category.scheduled_category'
end
# Learn more: http://github.com/javan/whenever
