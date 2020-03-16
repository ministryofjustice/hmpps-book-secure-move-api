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
    filename = id + '.jpg'

    tempfile = Tempfile.new('temp.jpg').binmode
    tempfile.write image_blob
    tempfile.rewind

    image.attach(io: tempfile, filename: filename, content_type: 'image/jpg')
    tempfile.close

    filename
  end
end
