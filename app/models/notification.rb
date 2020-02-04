class Notification < ApplicationRecord
  belongs_to :subscription
  belongs_to :topic, polymorphic: true

  validates :time_stamp, presence: true
  validates :event_type, presence: true
  validates :topic, presence: true
  validates :data, presence: true
end
