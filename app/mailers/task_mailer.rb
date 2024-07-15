# frozen_string_literal: true

# Mailer class for sending task-related notifications.
class TaskMailer < ApplicationMailer
  default from: 'notifications@task.api'

  def reminder_email(user, task)
    @user = user
    @task = task
    @url  = 'http://localhost:3000/task'
    mail(to: @user.email, subject: 'Task Reminder')
  end
end
