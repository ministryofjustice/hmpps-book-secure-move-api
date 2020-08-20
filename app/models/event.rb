class Event < ApplicationRecord
  EVENT_NAMES = [
    NA = 'n/a'.freeze,
    CREATE = 'create'.freeze,
    UPDATE = 'update'.freeze,
    CANCEL = 'cancel'.freeze,
    UNCANCEL = 'uncancel'.freeze,
    COMPLETE = 'complete'.freeze,
    UNCOMPLETE = 'uncomplete'.freeze,
    REDIRECT = 'redirect'.freeze,
    START = 'start'.freeze,
    LOCKOUT = 'lockout'.freeze,
    LODGING = 'lodging'.freeze,
    ACCEPT = 'accept'.freeze,
    APPROVE = 'approve'.freeze,
    REJECT = 'reject'.freeze,
  ].freeze

  belongs_to :eventable, polymorphic: true, touch: true

  validates :eventable, presence: true
  validates :event_name, presence: true, inclusion: { in: EVENT_NAMES }, unless: ->(event) { event.type.present? }
  validates :client_timestamp, presence: true
  validates :details, presence: true, unless: ->(event) { event.type.present? }

  scope :default_order, -> { order(client_timestamp: :asc) }

  serialize :details, HashWithIndifferentAccessSerializer

  def supplier_id
    @supplier_id ||= details[:supplier_id]
  end

  def event_params
    @event_params ||= details[:event_params]
  end

  def data_params
    @data_params ||= details[:data_params]
  end

  # NB: Dynamic attributes for each event are all in the jsonb details column. Static attributes that are common and validated on all events are now flattened as individual columns in their own right. These include the client_timestamp and notes columns.
  # This will be simplified once suppliers have migrated to the generic events structure.
  def notes
    @notes ||= super || event_params.dig(:attributes, :notes)
  end

  def from_location
    @from_location ||= Location.find_by(id: event_params&.dig(:relationships, :from_location, :data, :id))
  end

  def to_location
    @to_location ||= Location.find_by(id: event_params&.dig(:relationships, :to_location, :data, :id))
  end

  def for_feed
    attributes.as_json
  end
end
