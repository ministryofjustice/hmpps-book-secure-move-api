# frozen_string_literal: true

class FrameworkResponse
  class DetailsObject
    include ActiveModel::Validations

    attr_accessor :question_options, :details_options, :option, :details

    validates :option, presence: true
    validates :option, inclusion: { in: :question_options }, if: :question_options
    validates :details, presence: true, if: :details_options

    def initialize(attributes: {}, question_options: [], details_options: [])
      @question_options = question_options.presence
      @details_options = details_options.presence
      attributes = attributes.presence || {}

      attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)
      @option = attributes[:option]
      @details = attributes[:details]
    end

    def as_json(_options = {})
      return {} unless option.present? || details.present?

      {
        option: option,
        details: details,
      }
    end
  end
end
