class Notification < ApplicationRecord
  belongs_to :subscription

  validates :time_stamp, presence: true
  validates :event_type, presence: true
  validates :object_id, presence: true
  validates :object_type, presence: true
  validates :data, presence: true
end
