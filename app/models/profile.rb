# frozen_string_literal: true

class Profile < VersionedModel
  before_validation :set_assessment_answers

  belongs_to :person

  has_one :move, dependent: :nullify

  has_many :documents, -> { kept }, as: :documentable, dependent: :destroy, inverse_of: :documentable

  validates :person, presence: true

  validate :validate_assessment_answers
  attribute :assessment_answers, Types::Jsonb.new(Profile::AssessmentAnswers)
  attribute :profile_identifiers, Types::Jsonb.new(Profile::ProfileIdentifiers)

  # Need to check whether this update actually involves a change, otherwise there will be a papertrail log
  # full of update records where nothing actually changes - making the audit next to useless.
  def merge_assessment_answers!(new_assessment_answers, category)
    new_list =
      assessment_answers.reject { |a| a.category == category } +
      manually_created_assessment_answers.select { |a| a.category == category } +
      new_assessment_answers

    deleted = assessment_answers.reject { |a| new_list.map(&:assessment_question_id).include?(a.assessment_question_id) }
    inserted = new_list.reject { |a| assessment_answers.map(&:assessment_question_id).include?(a.assessment_question_id) }
    changed = new_list.select do |a|
      answer = assessment_answers.detect { |aa| aa.assessment_question_id == a.assessment_question_id }
      answer && answer.attributes != a.attributes
    end

    unless deleted.empty? && inserted.empty? && changed.empty?
      self.assessment_answers = new_list
    end
  end

private

  def manually_created_assessment_answers
    assessment_answers.reject(&:imported_from_nomis)
  end

  def set_assessment_answers
    assessment_answers.each(&:set_timestamps)
    assessment_answers.each(&:copy_question_attributes)
  end

  def validate_assessment_answers
    return if assessment_answers.all?(&:valid?)

    errors.add(:assessment_answers, 'One or more assessment answers is invalid')
  end
end
