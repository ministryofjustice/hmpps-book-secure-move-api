class Event < ApplicationRecord
  EVENT_NAMES = [
    CREATE = 'create'.freeze,
    UPDATE = 'update'.freeze,
    CANCEL = 'cancel'.freeze,
    UNCANCEL = 'uncancel'.freeze,
    COMPLETE = 'complete'.freeze,
    UNCOMPLETE = 'uncomplete'.freeze,
    REDIRECT = 'redirect'.freeze,
    LOCKOUT = 'lockout'.freeze,
  ].freeze

  belongs_to :eventable, polymorphic: true

  validates :eventable, presence: true
  validates :event_name, presence: true, inclusion: { in: EVENT_NAMES }
  validates :client_timestamp, presence: true
  validates :details, presence: true

  scope :default_order, -> { order(client_timestamp: :asc) }

  serialize :details, HashWithIndifferentAccessSerializer

  def supplier_id
    @supplier_id ||= details.dig(:supplier_id)
  end

  def event_params
    @event_params ||= details.dig(:event_params)
  end

  def data_params
    @data_params ||= details.dig(:data_params)
  end

  def notes
    @notes ||= event_params.dig(:attributes, :notes)
  end
end
