# frozen_string_literal: true

class FrameworkFlag < VersionedModel
  enum :flag_type, {
    information: 'information',
    attention: 'attention',
    warning: 'warning',
    alert: 'alert',
  }

  validates :flag_type, presence: true, inclusion: { in: flag_types }
  validates :title, presence: true
  validates :question_value, presence: true

  belongs_to :framework_question
  has_and_belongs_to_many :framework_responses
end
