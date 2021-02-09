# frozen_string_literal: true

class Notification < ApplicationRecord
  include Discard::Model

  FEED_ATTRIBUTES = %w[
    id
    event_type
    topic_id
    topic_type
    delivery_attempts
    delivery_attempted_at
    delivered_at
    discarded_at
    created_at
    updated_at
    response_id
    notification_type_id
  ].freeze

  belongs_to :subscription
  belongs_to :notification_type # NB: should be either NotificationType::WEBHOOK or NotificationType::EMAIL
  belongs_to :topic, polymorphic: true, touch: true # NB: polymorphic association because topic could be associated with a Move or a Profile

  validates :event_type, presence: true
  validates :topic, presence: true

  # A notification is kept if it is not discarded AND if its parent subscription is also kept
  scope :kept, -> { undiscarded.joins(:subscription).merge(Subscription.kept) }
  scope :webhooks, -> { where(notification_type: NotificationType::WEBHOOK) }
  scope :emails, -> { where(notification_type: NotificationType::EMAIL) }
  scope :default_order, -> { order(created_at: :asc) }

  def kept?
    # this notification is only kept if it is not discarded and its parent subscription is not discarded
    !discarded? && subscription.kept?
  end

  def for_feed
    attributes.slice(*FEED_ATTRIBUTES)
  end

  def mailer
    if topic.is_a?(PersonEscortRecord)
      PersonEscortRecordMailer
    else
      MoveMailer
    end
  end
end
