# frozen_string_literal: true

module V2
  class PersonWithCategorySerializer < ::V2::PersonSerializer
    include JSONAPI::Serializer

    set_type :people

    # NB: we need to lazy load the category to prevent an unnecessary call to Nomis
    has_one :category, serializer: CategorySerializer, lazy_load_data: true, &:category

    SUPPORTED_RELATIONSHIPS = %w[ethnicity gender profiles category].freeze
  end
end
