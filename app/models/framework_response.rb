# frozen_string_literal: true

class FrameworkResponse < VersionedModel
  ValueTypeError = Class.new(StandardError)

  validates :type, presence: true
  validates :responded, inclusion: { in: [true, false] }
  validates_each :value, on: :update do |record, _attr, value|
    record.errors.add(:value, :blank) if requires_value?(value, record)
  end

  belongs_to :framework_question
  belongs_to :person_escort_record
  has_many :dependents, class_name: 'FrameworkResponse',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkResponse', optional: true
  has_and_belongs_to_many :framework_flags, autosave: true

  after_validation :set_responded_value, on: :update

  def update_with_flags!(value)
    ActiveRecord::Base.transaction do
      self.value = value
      return unless value_text_changed? || value_json_changed?

      rebuild_flags
      save!
      self.class.clear_dependent_values_and_flags!([self])

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

  def rebuild_flags
    self.framework_flags = framework_question.framework_flags.select { |flag| option_selected?(flag.question_value) }
  end

  def self.requires_value?(value, record)
    return false if value.present? || !record.framework_question.required

    return true if record.parent.blank?

    record.parent.option_selected?(record.framework_question.dependent_value)
  end

  def self.clear_dependent_values_and_flags!(responses_to_update)
    all_dependent_ids = responses_to_update.map do |r|
      r.dependents.includes(:framework_question, :parent).reject { |dependent| r.option_selected?(dependent.framework_question.dependent_value) }
    end

    update_dependent_responses!(all_dependent_ids.flatten)
  end

  def self.update_dependent_responses!(dependent_ids)
    return unless dependent_ids.any?

    descendants = descendants_tree(dependent_ids).includes(:framework_question, :framework_flags).map do |descendant|
      descendant.assign_attributes(
        value: nil,
        responded: false,
        framework_flags: [],
      )

      descendant
    end

    import(descendants, validate: false, recursive: true, all_or_none: true, on_duplicate_key_update: %i[value_json value_text responded])
  end

  def self.descendants_tree(ids)
    where("framework_responses.id IN (#{recursive_tree})", ids)
  end

  def self.recursive_tree
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

private

  def set_responded_value
    self.responded = true
  end
end
