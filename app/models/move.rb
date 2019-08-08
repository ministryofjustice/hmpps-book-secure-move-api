# frozen_string_literal: true

class Move < ApplicationRecord
  enum status: {
    requested: 'requested',
    cancelled: 'cancelled'
  }

  enum move_type: {
    court_appearance: 'court_appearance',
    prison_recall: 'prison_recall',
    prison_transfer: 'prison_transfer'
  }

  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'
  belongs_to :person

  validates :from_location, presence: true
  validates :to_location, presence: true
  validates :date, presence: true
  validates :move_type, inclusion: { in: move_types }
  validates :person, presence: true
  validates :reference, presence: true
  validates :status, inclusion: { in: statuses }

  before_validation :set_reference

  private

  def set_reference
    self.reference ||= Moves::ReferenceGenerator.new.call
  end
end
