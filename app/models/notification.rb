class Notification < ApplicationRecord
  belongs_to :subscription
  belongs_to :topic, polymorphic: true

  validates :time_stamp, presence: true
  validates :event_type, presence: true
  validates :topic, presence: true
  validates :data, presence: true

  enum event_type: {
    move_created: 'move_created',
    move_updated: 'move_updated',
    move_deleted: 'move_deleted',
    person_created: 'person_created',
    person_updated: 'person_updated',
    person_deleted: 'person_deleted',
  }
end
