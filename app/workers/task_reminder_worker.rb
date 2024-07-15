# frozen_string_literal: true

# Worker class for sending reminder emails for tasks.
class TaskReminderWorker
  include Sidekiq::Worker

  def perform(task_id)
    task = Task.find(task_id)
    user = task.user
    assigned_user = task.assigned_user

    log_processing(task, user)
    process_task_reminder(task, user, assigned_user)
  rescue StandardError => e
    log_error(task_id, e)
    raise e
  end

  private

  def process_task_reminder(task, user, assigned_user)
    if task.reminder_needed?
      send_reminder_emails(task, user, assigned_user)
    else
      log_no_reminder_needed(task)
    end
  end

  def send_reminder_emails(task, user, assigned_user)
    send_email_to_assigned_user(task, assigned_user) if assigned_user && assigned_user != user
    send_email_to_user(task, user)
    update_task_reminder_timestamp(task)
  end

  def send_email_to_assigned_user(task, assigned_user)
    TaskMailer.reminder_email(assigned_user, task).deliver_later
    Rails.logger.info("TaskReminderWorker: Reminder email sent, user ID=#{assigned_user.id}, task ID=#{task.id}")
  end

  def send_email_to_user(task, user)
    TaskMailer.reminder_email(user, task).deliver_later
    Rails.logger.info("TaskReminderWorker: Reminder email sent, Admin ID=#{user.id}, task ID=#{task.id}")
  end

  def update_task_reminder_timestamp(task)
    task.update(last_reminder_sent_at: Time.current)
    Rails.logger.info("TaskReminderWorker: Updated last_reminder_sent_at for task ID=#{task.id}")
  end

  def log_processing(task, user)
    Rails.logger.info("TaskReminderWorker: Processing task ID=#{task.id} for user ID=#{user.id}")
  end

  def log_no_reminder_needed(task)
    Rails.logger.info("TaskReminderWorker: Task ID=#{task.id} does not need a reminder email")
  end

  def log_error(task_id, error)
    Rails.logger.error("TaskReminderWorker: Error processing task ID=#{task_id} - #{error.message}")
  end
end
