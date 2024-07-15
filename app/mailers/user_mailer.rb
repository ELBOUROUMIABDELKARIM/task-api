class UserMailer < ApplicationMailer
  default from: 'karim@task.api'

  def assigned_email(user, task)
    @user = user
    @task = task
    @url  = 'http://localhost:3000/task'
    mail(to: @user.email, subject: 'New Task')
  end
end