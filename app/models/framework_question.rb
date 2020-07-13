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
end
