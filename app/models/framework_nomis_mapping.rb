# frozen_string_literal: true

class FrameworkNomisMapping < VersionedModel
  enum code_type: {
    alert: 'alert',
    assessment: 'assessment',
    contact: 'contact',
    personal_care_need: 'personal_care_need',
    reasonable_adjustment: 'reasonable_adjustment',
  }

  validates :raw_nomis_mapping, presence: true
  validates :code, presence: true
  validates :code_type, presence: true, inclusion: { in: code_types }

  has_and_belongs_to_many :framework_responses
end
