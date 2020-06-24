# frozen_string_literal: true

class FrameworkQuestion < VersionedModel
  validates :key, presence: true
  validates :section, presence: true
  validates :question_type, presence: true

  belongs_to :framework
  has_many :dependents, class_name: 'FrameworkQuestion',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkQuestion', optional: true
end
