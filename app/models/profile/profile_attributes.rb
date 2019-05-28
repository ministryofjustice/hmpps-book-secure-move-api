class Profile::ProfileAttributes
  extend Forwardable

  def_delegators :@collection, *[].public_methods

  def initialize(array = [])
    collection = Array(array).map do |profile_attribute|
      profile_attribute.is_a?(Profile::ProfileAttribute) ? tier : Profile::ProfileAttribute.new(profile_attribute)
    end

    @collection = collection.reject(&:empty?)
  end

  def to_a
    @collection
  end
end
