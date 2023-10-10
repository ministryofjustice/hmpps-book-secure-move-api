# frozen_string_literal: true

class FrameworkResponse
  class DetailsObject
    include ActiveModel::Validations

    attr_accessor :question_options, :details_options, :option, :details

    validates :option, presence: true, if: :details
    validates :option, inclusion: { in: :question_options }, if: :question_options_and_option_present?
    validates :details, presence: true, if: :included_in_detail_options?

    def initialize(attributes: {}, question_options: [], details_options: [])
      @question_options = question_options
      @details_options = details_options
      attributes = attributes.presence || {}

      attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)
      @option = attributes[:option]
      @details = attributes[:details]
    end

    def as_json(_options = {})
      return {} unless option.present? || details.present?

      {
        option:,
        details: details.to_s.presence,
      }
    end

  private

    def included_in_detail_options?
      details_options.include?(option)
    end

    def question_options_and_option_present?
      question_options.any? && option.present?
    end
  end
end
