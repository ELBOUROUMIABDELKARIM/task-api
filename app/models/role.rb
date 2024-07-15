class Role < ApplicationRecord
  has_many :users

  ADMIN = 'admin'
  MODERATOR = 'moderator'
  USER = 'user'
end
