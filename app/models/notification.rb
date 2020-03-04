# frozen_string_literal: true

class Notification < ApplicationRecord
  include Discard::Model

  belongs_to :subscription
  belongs_to :notification_type
  belongs_to :topic, polymorphic: true # NB: polymorphic association because it could be associated with a Move or a Profile

  validates :event_type, presence: true
  validates :topic, presence: true

  # A notification is kept if it is not discarded AND if its parent subscription is also kept
  scope :kept, -> { undiscarded.joins(:subscription).merge(Subscription.kept) }

  def kept?
    # this notification is only kept if it is not discarded and its parent subscription is not discarded
    !discarded? && subscription.kept?
  end
end
