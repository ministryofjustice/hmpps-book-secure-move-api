# frozen_string_literal: true

class Person < ApplicationRecord
  has_many :profiles
  has_many :moves

  def latest_profile
    profiles.last
  end
end
