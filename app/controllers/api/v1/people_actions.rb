module Api::V1
  module PeopleActions
    PERSON_ATTRIBUTES = [
      :first_names,
      :last_name,
      :date_of_birth,
      :gender_additional_information,
      { assessment_answers: [%i[key
                                date
                                expiry_data
                                category
                                title
                                comments
                                assessment_question_id
                                nomis_alert_type
                                nomis_alert_type_description
                                nomis_alert_code
                                nomis_alert_description
                                created_at
                                expires_at
                                imported_from_nomis]],
        identifiers: [%i[value identifier_type]] },
    ].freeze
    PERMITTED_PERSON_PARAMS = [:type, { attributes: PERSON_ATTRIBUTES, relationships: {} }].freeze

    def index_and_render
      prison_number = filter_params[:prison_number]&.upcase

      import_person_from_nomis(prison_number) if prison_number

      people = People::Finder.new(filter_params).call

      paginate people, serializer: PersonSerializer, include: included_relationships
    end

    def show_and_render
      raise NotSupportedInOldVersionError
    end

    def create_and_render
      creator.call
      render_person(creator.person, 201)
    end

    def update_and_render
      updater.call
      # NB: it is known and currently accepted that raising notifications on the patch-people endpoint will lead to
      # duplicate move notifications (see P4-1357)
      Notifier.prepare_notifications(topic: updater.person, action_name: 'update')
      render_person(updater.person, 200)
    end

  private

    def render_person(person, status)
      render_json person, serializer: PersonSerializer, include: included_relationships, status:
    end

    def creator
      @creator ||= People::Creator.new(person_params)
    end

    def updater
      @updater ||= People::Updater.new(person, person_params)
    end

    def person_params
      params.require(:data).permit(PERMITTED_PERSON_PARAMS).to_h
    end

    def import_person_from_nomis(prison_number)
      # This prevents us from blaming the current user/application for the NOMIS sync
      PaperTrail.request(whodunnit: nil) do
        Moves::ImportPeople.new([prison_number]).call
      end
    end

    def supported_relationships
      PersonSerializer::SUPPORTED_RELATIONSHIPS
    end

    def included_relationships
      include_params_handler.included_relationships || PersonSerializer::SUPPORTED_RELATIONSHIPS
    end

    def other_included_relationships
      # Custom included relationships to avoid the people actions relationships
      @other_included_relationships ||= include_params_handler.included_relationships || Api::PeopleController::OTHER_SUPPORTED_RELATIONSHIPS
    end
  end
end
