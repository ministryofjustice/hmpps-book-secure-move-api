# frozen_string_literal: true

class Person < VersionedModel
  has_many :profiles, dependent: :destroy

  has_many :moves, through: :profiles

  has_one_attached :image

  def latest_profile
    profiles.order(:updated_at).last
  end

  delegate :latest_nomis_booking_id, to: :latest_profile

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
