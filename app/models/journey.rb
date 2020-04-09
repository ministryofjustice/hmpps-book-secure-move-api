class Journey < ApplicationRecord
  belongs_to :move
  belongs_to :supplier
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'

  validates :move, presence: true
  validates :supplier, presence: true
  validates :from_location, presence: true
  validates :to_location, presence: true
  validates :client_timestamp, presence: true

  validates :billable, exclusion: { in: [nil] }
  validates :completed, exclusion: { in: [nil] }
  validates :cancelled, exclusion: { in: [nil] }

  scope :default_order, -> { order(client_timestamp: :desc) }
end
