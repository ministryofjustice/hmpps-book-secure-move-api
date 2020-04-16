class Event < ApplicationRecord
  belongs_to :move

  enum event_types: {
    move_created: 'move_created',
    move_updated: 'move_updated',
    move_completed: 'move_completed',
    move_cancelled: 'move_cancelled',
    move_redirected: 'move_redirected',
    move_lockout: 'move_lockout',
    journey_created: 'journey_created',
    journey_updated: 'journey_updated',
    journey_completed: 'journey_completed',
    journey_uncompleted: 'journey_uncompleted',
    journey_cancelled: 'journey_cancelled',
    journey_uncancelled: 'journey_uncancelled',
  }

  validates :move, presence: true
  validates :event_type, presence: true, inclusion: { in: event_types }
  validates :client_timestamp, presence: true

  scope :default_order, -> { order(client_timestamp: :asc) }
end
