# frozen_string_literal: true

class FrameworkQuestion < VersionedModel
  enum question_type: {
    radio: 'radio',
    checkbox: 'checkbox',
    text: 'text',
    textarea: 'textarea',
  }

  validates :key, presence: true
  validates :section, presence: true
  validates :question_type, presence: true, inclusion: { in: question_types }

  belongs_to :framework
  has_many :dependents, class_name: 'FrameworkQuestion',
                        foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'FrameworkQuestion', optional: true

  has_many :flags
  has_many :framework_responses

  def build_responses(question: self, person_escort_record:)
    response = build_response(question, person_escort_record)
    return response unless question.dependents.any?

    question.dependents.find_each do |dependent_question|
      dependent_response = build_responses(question: dependent_question, person_escort_record: person_escort_record)
      dependent_response_values = dependent_response.slice(:type, :framework_question_id, :dependents, :person_escort_record)

      response.dependents.build(dependent_response_values)
    end

    response
  end

  private

  def build_response(question, person_escort_record)
    klass =
      case question.question_type
      when 'radio'
        question.followup_comment ? FrameworkResponse::Object : FrameworkResponse::String
      when 'checkbox'
        question.followup_comment ? FrameworkResponse::Collection : FrameworkResponse::Array
      else
        FrameworkResponse::String
      end

    klass.new(framework_question_id: question.id, person_escort_record: person_escort_record)
  end
end
