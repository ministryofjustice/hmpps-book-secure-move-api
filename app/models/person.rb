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
  validate :validate_pnc

  auto_strip_attributes :nomis_prison_number, :prison_number, :criminal_records_office, :police_national_computer

  def age
    # See: https://medium.com/@craigsheen/calculating-age-in-rails-9bb661f11303
    @age ||= (TimeSince.new(date_of_birth.in_time_zone).get / 1.year.seconds).floor if date_of_birth.present?
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

  def self.is_valid_pnc?(pnc)
    return true if pnc.blank?

    pnc = pnc.to_s.upcase
    regex = /^([0-9]{2}|[0-9]{4})\/[0-9]+[A-Z]$/
    return false if regex.match(pnc).nil?

    mod23chars = 'ZABCDEFGHJKLMNPQRTUVWXY'.split('')
    year, number = pnc.split('/')
    check_digit = pnc.last
    derived_pnc = "#{year.last(2)}#{number[..-2].rjust(7, '0')}"
    i = derived_pnc.to_i % 23
    return false if mod23chars[i] != check_digit

    true
  end

private

  def validate_age
    return if date_of_birth.blank? || date_of_birth.year >= 1900

    errors.add(:birth_date, 'must be after 1900-01-01.')
  end

  def validate_pnc
    return if self.class.is_valid_pnc?(police_national_computer)

    errors.add(:police_national_computer, 'must be in the correct format. (e.g. 08/012345P)')
  end
end
