# frozen_string_literal: true

class FrameworkResponse < VersionedModel
  enum value_type: {
    string: 'string',
    list: 'list',
    text: 'text',
    json: 'json',
  }

  validates :value_type, presence: true, inclusion: { in: value_types }

  belongs_to :framework_question
  belongs_to :person_escort_record
  has_many :dependents, class_name: 'FrameworkResponse',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkResponse', optional: true
  has_and_belongs_to_many :flags, optional: true
end
