# frozen_string_literal: true

class Person < VersionedModel
  FEED_ATTRIBUTES = %w[
    id
    created_at
    updated_at
    first_names
    last_name
    date_of_birth
    gender_additional_information
    criminal_records_office
    nomis_prison_number
    police_national_computer
    prison_number
    last_synced_with_nomis
    latest_nomis_booking_id
  ].freeze

  IDENTIFIER_TYPES = %i[
    police_national_computer criminal_records_office prison_number
  ].freeze

  has_many :profiles, dependent: :destroy
  has_many :moves, through: :profiles
  belongs_to :ethnicity, optional: true
  belongs_to :gender, optional: true

  has_one_attached :image

  scope :ordered_by_name, ->(direction) { order('last_name' => direction, 'first_names' => direction) }
  scope :search_by_last_name, ->(search) { select(:id).where('last_name ILIKE :search', search: "%#{search}%") }
  scope :updated_at_range, lambda { |from, to|
    where(updated_at: from..to)
  }

  validates :last_name, presence: true
  validates :first_names, presence: true

  def latest_profile
    profiles.order(:updated_at).last
  end

  def attach_image(image_blob)
    "#{id}.jpg".tap do |filename|
      image_io = StringIO.new(image_blob).binmode
      begin
        image.attach(io: image_io, filename: filename, content_type: 'image/jpg')
      ensure
        image_io.close
      end
    end
  end

  def for_feed
    feed_attributes = attributes.slice(*FEED_ATTRIBUTES)

    feed_attributes.merge!(gender.for_feed) if gender
    feed_attributes.merge!(ethnicity.for_feed) if ethnicity

    feed_attributes
  end
end
