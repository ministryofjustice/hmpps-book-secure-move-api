# frozen_string_literal: true

class FrameworkResponse < VersionedModel
  validates :type, presence: true
  validates :responded, inclusion: { in: [true, false] }

  belongs_to :framework_question
  belongs_to :person_escort_record
  has_many :dependents, class_name: 'FrameworkResponse',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkResponse', optional: true
  has_and_belongs_to_many :flags
  validates_each :value, on: :update do |record, _attr, value|
    record.errors.add(:value, :blank) if requires_value?(value, record)
  end

  after_validation :set_responded_value, on: :update

  def self.requires_value?(value, record)
    return false if value.present? || !record.framework_question.required

    return true if record.parent.blank?

    record.parent.option_selected?(record.framework_question.dependent_value)
  end

private

  def set_responded_value
    self.responded = true
  end
end
