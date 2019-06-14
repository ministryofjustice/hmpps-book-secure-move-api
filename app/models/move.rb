# frozen_string_literal: true

class Move < ApplicationRecord
  enum status: {
    requested: 'requested',
    cancelled: 'cancelled'
  }

  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'
  belongs_to :person

  validates :from_location, presence: true
  validates :to_location, presence: true
  validates :date, presence: true
  validates :person, presence: true
  validates :status, inclusion: { in: statuses }
  validates :move_type, presence: true
  validates :reference, presence: true

  before_validation :set_reference

  private

  def set_reference
    self.reference ||= Moves::ReferenceGenerator.new.call
  end
end
