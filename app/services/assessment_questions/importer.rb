# frozen_string_literal: true

module AssessmentQuestions
  class Importer
    ASSESSMENT_QUESTIONS = [
      { key: :violent, category: :risk, title: 'Violent' },
      { key: :escape, category: :risk, title: 'Escape' },
      { key: :civil_disorder, category: :risk, title: 'Civil disorder' },
      { key: :hold_separately, category: :risk, title: 'Must be held separately' },
      { key: :self_harm, category: :risk, title: 'Self harm' },
      { key: :concealed_items, category: :risk, title: 'Concealed items' },
      { key: :not_to_be_released, category: :risk, title: 'Not to be released' },
      { key: :other_risks, category: :risk, title: 'Any other risks' },
      { key: :special_diet_or_allergy, category: :health, title: 'Special diet or allergy' },
      { key: :health_issue, category: :health, title: 'Health issue' },
      { key: :medication, category: :health, title: 'Medication' },
      { key: :wheelchair, category: :health, title: 'Wheelchair user' },
      { key: :pregnant, category: :health, title: 'Pregnant' },
      { key: :other_health, category: :health, title: 'Any other requirements' },
      { key: :special_vehicle, category: :health, title: 'Requires special vehicle' },
      { key: :solicitor, category: :court, title: 'Solicitor or other legal representation' },
      { key: :interpreter, category: :court, title: 'Sign or other language interpreter' },
      { key: :other_court, category: :court, title: 'Any other information' },
    ].freeze

    def call
      ASSESSMENT_QUESTIONS.each do |attributes|
        AssessmentQuestion
          .find_or_initialize_by(key: attributes[:key])
          .update(attributes.slice(:category, :title))
      end
    end
  end
end
