# frozen_string_literal: true

class Flag < VersionedModel
  validates :key, presence: true
  validates :name, presence: true
  validates :question_value, presence: true

  belongs_to :framework_question
end
