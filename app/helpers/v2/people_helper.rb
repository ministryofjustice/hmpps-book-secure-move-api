module V2
  module PeopleHelper
    def index_and_render
      # WIP!!!

      people = ::V2::People::Finder.new(filter_params).call

      paginate people, include: included_relationships, each_serializer: ::V2::PersonSerializer
    end

    def create_and_render
      person = Person.create(person_attributes)

      render_person(person, :created)
    end

    def update_and_render
      person = Person.find(params[:id])

      person.update!(person_attributes)
      Notifier.prepare_notifications(topic: person, action_name: 'update')

      render_person(person, :ok)
    end

  private

    PERMITTED_FILTER_PARAMS = %i[police_national_computer criminal_records_office prison_number].freeze

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

    def filter_params
      params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
    end

    def person_params
      params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
    end

    def person_attributes
      person_params[:attributes].merge(ethnicity: ethnicity, gender: gender)
    end

    def ethnicity
      ethnicity_id = params.require(:data).dig(:relationships, :ethnicity, :data, :id)
      Ethnicity.find(ethnicity_id) if ethnicity_id
    end

    def gender
      gender_id = params.require(:data).dig(:relationships, :gender, :data, :id)
      Gender.find(gender_id) if gender_id
    end

    def render_person(person, status)
      render json: person, status: status, include: included_relationships, serializer: ::V2::PersonSerializer
    end

    def supported_relationships
      ::V2::PersonSerializer::SUPPORTED_RELATIONSHIPS
    end
  end
end
