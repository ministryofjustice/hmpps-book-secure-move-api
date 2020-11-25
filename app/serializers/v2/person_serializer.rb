# frozen_string_literal: true

module V2
  class PersonSerializer
    include JSONAPI::Serializer

    set_type :people

    attributes(
      :first_names,
      :last_name,
      :date_of_birth,
      :gender_additional_information,
      :prison_number,
      :criminal_records_office,
      :police_national_computer,
    )

    has_one :ethnicity, serializer: EthnicitySerializer
    has_one :gender, serializer: GenderSerializer

    # TODO: replace this with has_many_if_included - lazy loading is buggy for nested resources
    # NB without lazy_load_data: true this relationship will trigger an N+1 database query,
    # unless it is included in the includes list
    has_many :profiles, serializer: ProfileSerializer, lazy_load_data: true

    SUPPORTED_RELATIONSHIPS = %w[ethnicity gender profiles].freeze
  end
end
