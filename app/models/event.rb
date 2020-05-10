class Event < ApplicationRecord
  belongs_to :entity, polymorphic: true

  EVENT_NAMES = %w[create update cancel uncancel complete uncomplete redirect lockout].freeze

  validates :entity, presence: true
  validates :event_name, presence: true, inclusion: { in: EVENT_NAMES }
  validates :client_timestamp, presence: true

  scope :default_order, -> { order(client_timestamp: :asc) }
end
