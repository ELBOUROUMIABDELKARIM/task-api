class AddLastReminderSentAtToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :last_reminder_sent_at, :datetime
  end
end
