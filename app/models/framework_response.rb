# frozen_string_literal: true

class FrameworkResponse < VersionedModel
  validates :type, presence: true
  validates :responded, inclusion: { in: [true, false] }

  belongs_to :framework_question
  belongs_to :person_escort_record
  has_many :dependents, class_name: 'FrameworkResponse',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkResponse', optional: true
  has_and_belongs_to_many :flags, autosave: true
  validates_each :value, on: :update do |record, _attr, value|
    record.errors.add(:value, :blank) if requires_value?(value, record)
  end

  after_validation :set_responded_value, on: :update

  def self.requires_value?(value, record)
    return false if value.present? || !record.framework_question.required

    return true if record.parent.blank?

    record.parent.option_selected?(record.framework_question.dependent_value)
  end

  def update_with_flags!(value)
    ActiveRecord::Base.transaction do
      old_value = self.value
      self.value = value

      update!(flags: build_flags)
      clear_dependent_values_and_flags!(old_value)
    end
  end

private

  def set_responded_value
    self.responded = true
  end

  def build_flags
    return [] unless framework_question.flags.any?

    framework_question.flags.each_with_object([]) do |flag, arr|
      if option_selected?(flag.question_value)
        arr << flag
      end
    end
  end

  def clear_dependent_values_and_flags!(old_value)
    return unless (old_value != value) && dependents.any?

    dependent_ids = dependents.includes(:framework_question).reject { |dependent| option_selected?(dependent.framework_question.dependent_value) }
    return unless dependent_ids.any?

    FrameworkResponse
      .where("framework_responses.id IN (#{recursive_tree})", dependent_ids)
      .update(value_json: nil, value_text: nil, flags: [])
  end

  def recursive_tree
    <<-SQL
      WITH RECURSIVE tree AS (
        -- initial node
        SELECT id, parent_id
          FROM framework_responses
          WHERE id IN (?) -- start from the root
        UNION all
        -- recursive descent
        SELECT fr.id, fr.parent_id
          FROM tree t
          JOIN framework_responses fr ON fr.parent_id = t.id AND fr.parent_id != fr.id
      )

      SELECT id FROM tree
    SQL
  end
end
