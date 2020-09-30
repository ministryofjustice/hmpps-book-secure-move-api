# frozen_string_literal: true

class FrameworkNomisMapping < VersionedModel
  validates :code, presence: true
  validates :code_type, presence: true
  validates :raw_nomis_mapping, presence: true
  # validates_date :start_date, :end_date, :creation_date, :expiry_date

  has_and_belongs_to_many :framework_responses, join_table: "framework_nomis_mappings_responses"
end
