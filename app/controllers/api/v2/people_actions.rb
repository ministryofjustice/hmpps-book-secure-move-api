module Api::V2
  module PeopleActions
    def index_and_render
      ::People::ImportFromNomis.new(prison_numbers).call if prison_numbers.present?

      people = V2::People::Finder.new(filter_params).call

      paginate people, serializer: ::V2::PersonSerializer, include: included_relationships
    end

    def create_and_render
      person = Person.create(person_attributes)

      render_person(person, :created)
    end

    def show_and_render
      render_person(person, :ok)
    end

    def update_and_render
      person = Person.find(params[:id])

      person.update!(person_attributes)
      Notifier.prepare_notifications(topic: person, action_name: 'update')

      render_person(person, :ok)
    end

  private

    PERSON_ATTRIBUTES = %i[
      first_names
      last_name
      date_of_birth
      prison_number
      criminal_records_office
      police_national_computer
      gender_additional_information
    ].freeze
    PERMITTED_PERSON_PARAMS = [:type, attributes: PERSON_ATTRIBUTES, relationships: {}].freeze

    def person_params
      params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
    end

    def person_attributes
      attributes = {}
      attributes.merge!(person_params.fetch(:attributes, {}))

      # Relationships are indicated in json:api via the relationships.<relationship_type> key
      #
      # Patch relationships to nil when the resource is supplied but it's data component is nil
      # Patch relationships to new relationship when the resource is supplied and the id references a resource that exists
      #
      # Do not patch the relationship if the resource is not supplied
      attributes[:ethnicity] = ethnicity if ethnicity_params
      attributes[:gender] = gender if gender_params

      attributes
    end

    def ethnicity_params
      params.require(:data).dig(:relationships, :ethnicity)
    end

    def ethnicity
      ethnicity_id = ethnicity_params.dig(:data, :id)

      Ethnicity.find(ethnicity_id) if ethnicity_id
    end

    def gender_params
      params.require(:data).dig(:relationships, :gender)
    end

    def gender
      gender_id = gender_params.dig(:data, :id)

      Gender.find(gender_id) if gender_id
    end

    def render_person(person, status)
      render_json person, serializer: ::V2::PersonWithCategorySerializer, include: included_relationships, status: status
    end

    def supported_relationships
      if action_name == 'index'
        ::V2::PersonSerializer::SUPPORTED_RELATIONSHIPS
      else
        ::V2::PersonWithCategorySerializer::SUPPORTED_RELATIONSHIPS
      end
    end

    def other_included_relationships
      included_relationships
    end

    def prison_numbers
      filter_params[:prison_number]&.split(',')&.map(&:upcase)
    end
  end
end
