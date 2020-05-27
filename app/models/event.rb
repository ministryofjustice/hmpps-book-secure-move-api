class Event < ApplicationRecord
  EVENT_NAMES = %w[create update cancel uncancel complete uncomplete redirect lockout].freeze

  belongs_to :eventable, polymorphic: true

  validates :eventable, presence: true
  validates :event_name, presence: true, inclusion: { in: EVENT_NAMES }
  validates :client_timestamp, presence: true
  validates :details, presence: true

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

  def notes
    @notes ||= event_params.dig(:attributes, :notes)
  end
end
