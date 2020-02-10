class Notification < ApplicationRecord
  belongs_to :subscription
  belongs_to :topic, polymorphic: true # NB: polymorphic association because it could be associated with a Move or a Profile

  validates :time_stamp, presence: true
  validates :event_type, presence: true
  validates :topic, presence: true
end
