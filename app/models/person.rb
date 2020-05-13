# frozen_string_literal: true

class Person < VersionedModel
  has_many :profiles, dependent: :destroy
  has_many :moves, dependent: :destroy

  has_one_attached :image

  def latest_profile
    profiles.last
  end

  def latest_nomis_booking_id
    latest_profile.latest_nomis_booking_id
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
