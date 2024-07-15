class MailerWorker
  include Sidekiq::Worker

  def perform(task_id)
    sleep(30)
    task = Task.find(task_id)
    user = task.assigned_user
    UserMailer.assigned_email(user, task).deliver_later
  end
end
