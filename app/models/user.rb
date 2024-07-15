# frozen_string_literal: true

# Represents a user in the application with roles and permissions.
class User < ApplicationRecord
  has_secure_password

  enum role: { admin: 0, moderator: 1, user: 2 }
  has_many :tasks, dependent: :destroy
  has_many :assigned_tasks, class_name: 'Task', foreign_key: 'assigned_user_id'
  after_initialize :set_default_role, if: :new_record?
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  def assign_to(user)
    update(assigned_user: user)
  end

  def role?(role_name)
    role == role_name.to_s
  end

  def can_create_task?
    role?(:admin)
  end

  def can_assign_task?
    role?(:moderator) || role?(:admin)
  end

  def can_update_task?(_task)
    role?(:admin) || role?(:moderator)
  end

  def can_delete_task?(_task)
    role?(:admin)
  end

  def can_view_task?(task)
    role?(:admin) || role?(:moderator) || (task.assigned_user == self)
  end

  private

  def set_default_role
    self.role ||= :user
  end
end
