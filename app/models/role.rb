# frozen_string_literal: true

# Represents a role that can be assigned to a user.
class Role < ApplicationRecord
  has_many :users

  ADMIN = 'admin'
  MODERATOR = 'moderator'
  USER = 'user'
end
