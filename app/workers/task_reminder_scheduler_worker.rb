# frozen_string_literal: true

# Worker class for scheduling task reminders.
class TaskReminderSchedulerWorker
  include Sidekiq::Worker

  def perform
    tasks_due_soon = Task.where(due_date: ..1.day.from_now, completed: false)
    #tasks_due_soon = Task.where('due_date <= ? AND completed = ?', 1.day.from_now, false)
    tasks_due_soon.find_each do |task|
      TaskReminderWorker.perform_async(task.id)
    end
    Rails.logger.info("TaskReminderSchedulerWorker: Scheduled reminders for #{tasks_due_soon.count} tasks.")
  rescue StandardError => e
    Rails.logger.error("TaskReminderSchedulerWorker: Error scheduling task reminders - #{e.message}")
  end
end
