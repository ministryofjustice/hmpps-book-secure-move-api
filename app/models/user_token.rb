# frozen_string_literal: true

class UserToken < ApplicationRecord
  validates :access_token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true
  validates :user_name, presence: true
  validates :user_id, presence: true
end

