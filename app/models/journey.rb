class Journey < ApplicationRecord
  belongs_to :move
  belongs_to :supplier
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'

  validates :billable, inclusion: { in: [true, false] }
  validates :completed, inclusion: { in: [true, false] }
  validates :cancelled, inclusion: { in: [true, false] }

  validates :move, presence: true
  validates :supplier, presence: true
  validates :from_location, presence: true
  validates :to_location, presence: true
  validates :client_timestamp, presence: true
end
