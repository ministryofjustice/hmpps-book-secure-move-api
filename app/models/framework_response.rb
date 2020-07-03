# frozen_string_literal: true

class FrameworkResponse < VersionedModel
  enum value_type: {
    string: 'string',
    array: 'array',
    text: 'text',
    json: 'json',
  }

  validates :value_type, presence: true, inclusion: { in: value_types }

  belongs_to :framework_question
  belongs_to :person_escort_record
  has_many :dependents, class_name: 'FrameworkResponse',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkResponse', optional: true
  has_and_belongs_to_many :flags, join_table: 'framework_responses_flags'

  validates :value_text, absence: true, if: -> { json? || array? }
  validates :value_json, absence: true, if: -> { string? || text? }

  def value
    case value_type
    when 'json'
      value_json.presence || '{}'
    when 'array'
      value_json.presence || []
    else
      value_text
    end
  end

  def value=(answer)
    case value_type
    when 'json'
      self.value_json = answer.presence || '{}'
    when 'array'
      self.value_json = answer.presence || []
    else
      self.value_text = answer
    end
  end
end
