# frozen_string_literal: true

# Worker class for sending reminder emails for tasks.
class TaskReminderWorker
  include Sidekiq::Worker

  def perform(task_id)
    task = Task.find(task_id)
    user = task.user
    assigned_user = task.assigned_user

    Rails.logger.info("TaskReminderWorker: Processing task ID=#{task.id} for user ID=#{user.id}")

    if task.reminder_needed?
      send_reminder_email(task, user, assigned_user)
    else
      Rails.logger.info("TaskReminderWorker: Task ID=#{task.id} does not need a reminder email")
    end
  rescue StandardError => e
    Rails.logger.error("TaskReminderWorker: Error processing task ID=#{task_id} - #{e.message}")
    raise e
  end

  private

  def send_reminder_email(task, user, assigned_user)
    if assigned_user && assigned_user != user
      TaskMailer.reminder_email(assigned_user, task).deliver_later
      Rails.logger.info("TaskReminderWorker: Reminder email sent to assigned user ID=#{assigned_user.id} for task ID=#{task.id}")
    end

    TaskMailer.reminder_email(user, task).deliver_later
    Rails.logger.info("TaskReminderWorker: Reminder email sent to Admin ID=#{user.id} for task ID=#{task.id}")

    task.update(last_reminder_sent_at: Time.current)
    Rails.logger.info("TaskReminderWorker: Updated last_reminder_sent_at for task ID=#{task.id}")
  end
end
