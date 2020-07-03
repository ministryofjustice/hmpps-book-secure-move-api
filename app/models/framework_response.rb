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

  def value
    json? ? value_json : value_text
  end

  def value=(answer)
    if json?
      value_json = answer
    else
      value_text = answer
    end
  end
end
