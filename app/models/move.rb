# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'
  belongs_to :person

  validates :from_location, presence: true
  validates :to_location, presence: true
  validates :date, presence: true
  validates :time_due, presence: true
  validates :person, presence: true
  validates :status, presence: true
  validates :move_type, presence: true
end
