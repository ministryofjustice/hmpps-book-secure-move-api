# frozen_string_literal: true

class Profile
  class AssessmentAnswers
    extend Forwardable

    def_delegators :@collection, *[].public_methods - %i[object_id __send__]

    def initialize(array = [])
      array = JSON.parse(array) if array.is_a? String
      collection = Array(array).map do |item|
        item.is_a?(Profile::AssessmentAnswer) ? item : Profile::AssessmentAnswer.new(item)
      end

      @collection = collection
    end

    def to_a
      @collection
    end
  end
end
