class Image
  include ActiveModel::Serialization

  attr_reader :id, :url

  def initialize(person_id, image_url)
    @id = person_id
    @url = image_url
  end
end
