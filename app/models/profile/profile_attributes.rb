# frozen_string_literal: true

class Profile
  class ProfileAttributes
    extend Forwardable

    def_delegators :@collection, *[].public_methods - %i[object_id __send__]

    def initialize(array = [])
      array = JSON.parse(array) if array.is_a? String
      collection = Array(array).map do |item|
        item.is_a?(Profile::ProfileAttribute) ? item : Profile::ProfileAttribute.new(item)
      end

      @collection = collection.reject(&:empty?)
    end

    def to_a
      @collection
    end
  end
end
