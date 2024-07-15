# frozen_string_literal: true

# Represents a task assigned to a user with optional assignment to another user.
class Task < ApplicationRecord
  belongs_to :user
  belongs_to :assigned_user, class_name: 'User', optional: true
  validates :title, presence: true
  validates :description, presence: true

  def assign_to(user)
    update(assigned_user: user)
  end

  def can_be_assigned_by?(user)
    user.can_assign_task?
  end

  def due_soon?
    due_date <= 1.day.from_now && !completed?
  end

  def reminder_needed?
    due_soon? && (last_reminder_sent_at.nil? || last_reminder_sent_at < 1.day.ago)
  end
end
