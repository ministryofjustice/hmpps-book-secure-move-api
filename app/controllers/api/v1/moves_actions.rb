module Api::V1
  module MovesActions
    def index_and_render
      paginate moves,
               serializer: MoveSerializer,
               include: included_relationships - %w[court_hearings]
    end

    def show_and_render
      render_move(move, :ok)
    end

    def create_and_render
      validate_move_status
      move = Move.new(new_move_attributes)

      move.supplier = doorkeeper_application_owner || SupplierChooser.new(move).call
      move.profile.documents = profile_documents

      authorize!(:create, move)
      move.save!

      log_with_request(:info, "V1 Move creation started - #{move.reference} #{move.status}")

      move.person.update_nomis_data if move.person.present?

      Notifier.prepare_notifications(topic: move, action_name: 'create')

      PrometheusMetrics.instance.record_move_count

      log_with_request(:info, "V1 Move creation finished - #{move.reference}")

      render_move(move, :created)
    end

    def update_and_render
      move.present? # verify the move exists before validations
      updater.call

      if updater.date_changed
        create_automatic_event!(
          eventable: move,
          event_class: GenericEvent::MoveDateChanged,
          details: { date: move.date.iso8601, date_changed_reason: move.date_changed_reason },
        )
      end

      Notifier.prepare_notifications(topic: updater.move, action_name: updater.status_changed ? 'update_status' : 'update')
      render_move(updater.move, :ok)
    end

  private

    PERMITTED_NEW_MOVE_PARAMS = [
      :type,
      { attributes: %i[date
                       time_due
                       status
                       move_type
                       additional_information
                       cancellation_reason
                       cancellation_reason_comment
                       reason_comment
                       move_agreed
                       move_agreed_by
                       date_from
                       date_to],
        relationships: {} },
    ].freeze
    PERMITTED_UPDATE_MOVE_PARAMS = [
      :type,
      { attributes: %i[date
                       time_due
                       status
                       additional_information
                       cancellation_reason
                       cancellation_reason_comment
                       reason_comment
                       move_agreed
                       move_agreed_by
                       date_from
                       date_to
                       date_changed_reason],
        relationships: {} },
    ].freeze

    def profile_documents
      ids = (new_move_params.dig(:relationships, :documents, :data) || []).map { |doc| doc[:id] }

      Document.where(id: ids)
    end

    def new_move_params
      params.require(:data).permit(PERMITTED_NEW_MOVE_PARAMS).to_h
    end

    def new_move_attributes
      new_move_params[:attributes].tap do |attributes|
        from_location = Location.find(new_move_params.dig(:relationships, :from_location, :data, :id))

        attributes.merge!(
          profile: profile_or_person_latest_profile,
          from_location:,
          to_location: Location.find_by(id: new_move_params.dig(:relationships, :to_location, :data, :id)),
          court_hearings: CourtHearing.where(id: (new_move_params.dig(:relationships, :court_hearings, :data) || []).map { |court_hearing| court_hearing[:id] }),
          prison_transfer_reason: PrisonTransferReason.find_by(id: new_move_params.dig(:relationships, :prison_transfer_reason, :data, :id)),
        )
      end
    end

    def validate_move_status
      status = update_move_params.fetch(:attributes, {})[:status]
      if status.present?
        validator = Moves::StatusValidator.new(status:, cancellation_reason: update_move_params.fetch(:attributes, {})[:cancellation_reason], rejection_reason: update_move_params.fetch(:attributes, {})[:rejection_reason])
        raise ActiveModel::ValidationError, validator unless validator.valid?
      end
      status
    end

    def profile_or_person_latest_profile
      profile_id = new_move_params.dig(:relationships, :profile, :data, :id)
      return Profile.find(profile_id) if profile_id

      # moves are always created against the latest_profile for the person if profile not provided
      Person.find(new_move_params.dig(:relationships, :person, :data, :id)).latest_profile
    end

    def update_move_params
      params.require(:data).permit(PERMITTED_UPDATE_MOVE_PARAMS).to_h
    end

    def render_move(move, status)
      render_json move, serializer: MoveSerializer, include: included_relationships, status:
    end

    def move
      @move ||= Move
        .accessible_by(current_ability)
        .includes(
          :from_location, :to_location, profile: { person: %i[gender ethnicity], person_escort_record: { framework_flags: :framework_question } }
        )
        .find(params[:id])
    end

    def updater
      @updater ||= Moves::Updater.new(move, update_move_params)
    end

    def included_relationships
      include_params_handler.included_relationships || MoveSerializer::SUPPORTED_RELATIONSHIPS
    end

    def active_record_relationships
      # NB: v1 API needs a hardcoded active_record_relationships as they are not usually provided in the request
      [
        :allocation,
        :supplier,
        :court_hearings,
        :prison_transfer_reason,
        :original_move,
        :from_location,
        :to_location,
        { profile: [:documents, { person_escort_record: [:framework, :framework_responses, { framework_flags: :framework_question }] }],
          person: %i[gender ethnicity] },
      ]
    end

    def supported_relationships
      MoveSerializer::SUPPORTED_RELATIONSHIPS
    end
  end
end
