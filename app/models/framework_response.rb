# frozen_string_literal: true

class FrameworkResponse < VersionedModel
  ValueTypeError = Class.new(StandardError)

  validates :type, presence: true
  validates :responded, inclusion: { in: [true, false] }

  belongs_to :framework_question
  belongs_to :person_escort_record
  has_many :dependents, class_name: 'FrameworkResponse',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkResponse', optional: true
  has_and_belongs_to_many :framework_flags, autosave: true
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

      update!(framework_flags: build_flags)
      clear_dependent_values_and_flags!(old_value)

      # lock the status update to avoid race condition on multiple response patches
      person_escort_record.with_lock do
        person_escort_record.update_status!
      end
    end
  rescue FiniteMachine::InvalidStateError
    raise ActiveRecord::ReadOnlyRecord, "Can't update framework_responses because person_escort_record is #{person_escort_record.status}"
  end

  def value=(raw_value)
    unless raw_value.blank? || value_type_valid?(raw_value)
      raise FrameworkResponse::ValueTypeError, raw_value
    end
  end

private

  def set_responded_value
    self.responded = true
  end

  def build_flags
    return [] unless framework_question.framework_flags.any?

    framework_question.framework_flags.each_with_object([]) do |flag, arr|
      if option_selected?(flag.question_value)
        arr << flag
      end
    end
  end

  def clear_dependent_values_and_flags!(old_value)
    return unless old_value != value

    dependent_ids = dependents.includes(:framework_question).reject { |dependent| option_selected?(dependent.framework_question.dependent_value) }

    update_dependent_responses!(dependent_ids)
  end

  def update_dependent_responses!(dependent_ids)
    return unless dependent_ids.any?

    descendants = descendants_tree(dependent_ids).includes(:framework_question, :framework_flags).map do |descendant|
      descendant.assign_attributes(
        value: nil,
        responded: false,
        framework_flags: [],
      )

      descendant
    end

    FrameworkResponse.import(descendants, validate: false, recursive: true, all_or_none: true, on_duplicate_key_update: %i[value_json value_text responded])
  end

  def descendants_tree(ids)
    FrameworkResponse
      .where("framework_responses.id IN (#{recursive_tree})", ids)
  end

  def recursive_tree
    # build full descendants tree
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
