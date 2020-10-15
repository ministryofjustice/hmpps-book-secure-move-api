# frozen_string_literal: true

class V2::ProfileSerializer
  include JSONAPI::Serializer

  set_type :profiles

  attributes :assessment_answers

  belongs_to :person, serializer: ::V2::PersonSerializer, if: Proc.new { |_, params| params[:dot_relationships].include?('profile.person')}
  # has_many :documents, serializer: DocumentSerializer
  # has_one :person_escort_record, serializer: PersonEscortRecordSerializer

  SUPPORTED_RELATIONSHIPS = %w[documents person].freeze
end
