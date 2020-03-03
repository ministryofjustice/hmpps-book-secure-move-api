# frozen_string_literal: true

class Profile
  class ProfileIdentifiers
    extend Forwardable

    def_delegators :@collection, *[].public_methods - %i[object_id __send__]

    def initialize(array = [])
      array = JSON.parse(array) if array.is_a? String
      collection = Array(array).map do |item|
        item.is_a?(Profile::ProfileIdentifier) ? item : Profile::ProfileIdentifier.new(item)
      end

      add_alias_nomis_offender_no(collection)

      # binding.pry

      @collection = collection.reject(&:empty?)
    end

    def to_a
      @collection
    end

  private

    def add_alias_nomis_offender_no(collection)
      prison_number_identifier = collection.find { |e| e.identifier_type == 'prison_number' }
      nomis_offender_no_identifier = collection.find { |e| e.identifier_type == 'nomis_offender_no' }

      if prison_number_identifier && nomis_offender_no_identifier.nil?
        collection << Profile::ProfileIdentifier.new(value: prison_number_identifier.value, identifier_type: 'nomis_offender_no')
      end
    end
  end
end
