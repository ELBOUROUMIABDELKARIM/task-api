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

  def has_role?(role_name)
    role == role_name.to_s
  end

  def can_create_task?
    has_role?(:admin)
  end

  def can_assign_task?
    has_role?(:moderator) || has_role?(:admin)
  end

  def can_update_task?(task)
    has_role?(:admin) || has_role?(:moderator)
  end

  def can_delete_task?(task)
    has_role?(:admin)
  end

  def can_view_task?(task)
    has_role?(:admin) || has_role?(:moderator) || (task.assigned_user == self)
  end

  private

  def set_default_role
    self.role ||= :user
  end
end
