# frozen_string_literal: true

class Person < VersionedModel
  FEED_ATTRIBUTES = %w[
    id
    created_at
    updated_at
    criminal_records_office
    nomis_prison_number
    police_national_computer
    prison_number
    latest_nomis_booking_id
    first_names
    last_name
    date_of_birth
  ].freeze

  IDENTIFIER_TYPES = %i[
    police_national_computer criminal_records_office prison_number
  ].freeze

  has_many :profiles, dependent: :destroy
  has_many :moves, through: :profiles
  has_many :person_escort_records, through: :profiles
  has_many :youth_risk_assessments, through: :profiles
  has_many :generic_events, as: :eventable, dependent: :destroy

  belongs_to :ethnicity, optional: true
  belongs_to :gender, optional: true

  has_one_attached :image

  scope :ordered_by_name, ->(direction) { order('last_name' => direction, 'first_names' => direction) }
  scope :search_by_last_name, ->(search) { select(:id).where('last_name ILIKE :search', search: "%#{search}%") }

  validates :last_name, presence: true
  validates :first_names, presence: true
  validate :validate_age

  auto_strip_attributes :nomis_prison_number, :prison_number, :criminal_records_office, :police_national_computer

  def age
    # See: https://medium.com/@craigsheen/calculating-age-in-rails-9bb661f11303
    # rubocop:disable Rails/Date
    @age ||= ((Time.zone.now - date_of_birth.to_time) / 1.year.seconds).floor if date_of_birth.present?
    # rubocop:enable Rails/Date
  end

  def latest_profile
    profiles.max_by(&:updated_at)
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
    feed_attributes.merge!('age' => age) if age

    feed_attributes
  end

  def latest_person_escort_record
    person_escort_records.where(status: FrameworkAssessmentable::ASSESSMENT_CONFIRMED).order(confirmed_at: :desc).first
  end

  def latest_youth_risk_assessment
    youth_risk_assessments.where(status: FrameworkAssessmentable::ASSESSMENT_CONFIRMED).order(confirmed_at: :desc).first
  end

  def category
    @category ||= Categories::FindByNomisBookingId.new(latest_nomis_booking_id).call
  end

  def csra
    @csra ||= NomisClient::BookingDetails.get(latest_nomis_booking_id)[:csra]
  end

  def update_nomis_data
    People::RetrieveImage.call(self, force_update: true)
  end

private

  def validate_age
    if date_of_birth.present? && date_of_birth.year < 1900
      errors.add(:birth_date, 'must be after 1900-01-01.')
    end
  end
end
