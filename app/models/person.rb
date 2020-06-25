# frozen_string_literal: true

class Person < VersionedModel
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
end
