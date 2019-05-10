# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :person

  validates :person, presence: true
  validates :last_name, presence: true
  validates :first_names, presence: true
end
