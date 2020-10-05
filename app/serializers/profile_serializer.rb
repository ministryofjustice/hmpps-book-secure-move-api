# frozen_string_literal: true

class ProfileSerializer
  include JSONAPI::Serializer

  set_type :profiles

  attributes :assessment_answers

  belongs_to :person
  has_many :documents
  has_one :person_escort_record

  SUPPORTED_RELATIONSHIPS = %w[documents person].freeze
end
