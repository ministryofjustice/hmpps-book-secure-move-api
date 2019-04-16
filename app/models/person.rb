# frozen_string_literal: true

class Person < ApplicationRecord
  has_many :profiles
  has_many :moves
end
