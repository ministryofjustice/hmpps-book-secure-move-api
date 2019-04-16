# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :person

  validates :person, presence: true
  validates :surname, presence: true
  validates :forenames, presence: true
end
