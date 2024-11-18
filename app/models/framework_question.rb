# frozen_string_literal: true

class FrameworkQuestion < VersionedModel
  enum :question_type, {
    radio: 'radio',
    checkbox: 'checkbox',
    text: 'text',
    textarea: 'textarea',
    add_multiple_items: 'add_multiple_items',
  }

  validates :key, presence: true
  validates :section, presence: true
  validates :question_type, presence: true, inclusion: { in: question_types }

  belongs_to :framework
  has_many :dependents, class_name: 'FrameworkQuestion',
                        foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'FrameworkQuestion', optional: true

  has_many :framework_flags
  has_many :framework_responses
  has_and_belongs_to_many :framework_nomis_codes, autosave: true

  def build_responses(assessmentable:, questions:, question: self, previous_responses: {})
    response = build_response(question, assessmentable, previous_responses[question.key])
    return response if question.dependents.empty? || question.question_type == 'add_multiple_items'

    question.dependents.each do |dependent_question|
      # NB: to avoid extra queries use original set of questions
      dependent_response = build_responses(question: questions[dependent_question.id], assessmentable:, questions:, previous_responses:)
      dependent_response_values = dependent_response.slice(:type, :framework_question, :dependents, :assessmentable, :value, :prefilled, :value_type, :section)
      response.dependents.build(dependent_response_values)
    end

    response
  end

  def response_type
    case question_type
    when 'radio'
      followup_comment ? 'object::followup_comment' : 'string'
    when 'checkbox'
      followup_comment ? 'collection::followup_comment' : 'array'
    when 'add_multiple_items'
      'collection::add_multiple_items'
    else
      'string'
    end
  end

  def build_response(question, assessmentable, previous_response = nil)
    klass =
      case question.question_type
      when 'radio'
        question.followup_comment ? FrameworkResponse::Object : FrameworkResponse::String
      when 'checkbox'
        question.followup_comment ? FrameworkResponse::Collection : FrameworkResponse::Array
      when 'add_multiple_items'
        FrameworkResponse::Collection
      else
        FrameworkResponse::String
      end

    klass.new(framework_question: question, assessmentable:, value_type: question.response_type, value: previous_response, section: question.section, prefilled: previous_response.present?)
  rescue FrameworkResponse::ValueTypeError
    klass.new(framework_question: question, assessmentable:, value_type: question.response_type, section: question.section)
  end
end
