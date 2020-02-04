# frozen_string_literal: true

class Profile < VersionedModel
  before_validation :set_assessment_answers

  belongs_to :person
  belongs_to :ethnicity, optional: true
  belongs_to :gender, optional: true
  has_many :moves, dependent: :destroy

  validates :person, presence: true
  validates :last_name, presence: true
  validates :first_names, presence: true
  validate :validate_assessment_answers

  attribute :assessment_answers, Profile::AssessmentAnswers::Type.new
  attribute :profile_identifiers, Profile::ProfileIdentifiers::Type.new

  IDENTIFIER_TYPES = %w[
    police_national_computer criminal_records_office prison_number niche_reference athena_reference
  ].freeze

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

  def profile_identifiers=(new_identifiers)
    inserted = new_identifiers.reject do |new|
      profile_identifiers.map(&:identifier_type).include?(new[:identifier_type])
    end
    deleted = profile_identifiers.reject do |old|
      new_identifiers.map { |pi| pi[:identifier_type] }.include?(old.identifier_type)
    end
    changed = profile_identifiers.select do |old|
      new_id = new_identifiers.detect { |pi| pi[:identifier_type] == old.identifier_type }
      new_id && new_id[:value] != old.value
    end

    unless deleted.empty? && inserted.empty? && changed.empty?
      # self[:profile_identifiers] = new_identifiers
      super
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
