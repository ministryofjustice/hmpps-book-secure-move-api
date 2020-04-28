# frozen_string_literal: true

module Types
  class BaseCollection
    extend Forwardable

    def_delegators :@collection, *[].public_methods - %i[object_id __send__]

    def initialize(array = [])
      array = JSON.parse(array) if array.is_a? String
      collection = Array(array).map do |item|
        item.is_a?(concrete_class) ? item : concrete_class.new(item)
      end

      @collection = remove_empty_items? ? collection.reject(&:empty?) : collection
    end

    def to_a
      @collection
    end

    def concrete_class
      raise NotImplementedError
    end

    def remove_empty_items?
      false
    end
  end
end
