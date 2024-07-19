require 'sidekiq/cron/job'

Sidekiq::Cron::Job.create(
  name: 'Task reminders - every hour',
  cron: '* * * * *',
  class: 'TaskReminderSchedulerWorker'
)

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
