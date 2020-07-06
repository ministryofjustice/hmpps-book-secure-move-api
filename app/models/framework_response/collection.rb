class FrameworkResponse
  class Collection < FrameworkResponse
    validates :value_text, absence: true
    validate :validate_presence, on: :update, if: -> { framework_question.required }
    validate :validate_details_collection, on: :update, if: -> { response_details? }

    def self.sti_name
      'collection'
    end

    def value
      value_json.presence || []
    end

    def value=(answer)
      self.value_json =
        if response_details?
          details_collection(answer).to_a
        else
          self.value_json = answer.presence || []
        end
    end

  private

    def details_collection(collection)
      DetailsCollection.new(
        collection: collection,
        question_options: framework_question.options,
        details_options: framework_question.followup_comment_options,
      )
    end

    def validate_presence
      errors.add(:value_json, :presence) if value.empty?
    end

    def validate_details_collection
      # TODO: Add proper validation messages
      errors.add(:value, 'Details collection is invalid') if details_collection(value).invalid?
    end

    def response_details?
      framework_question.followup_comment
    end
  end
end
