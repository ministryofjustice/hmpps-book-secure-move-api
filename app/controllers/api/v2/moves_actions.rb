module Api::V2
  module MovesActions
    def index_and_render
      paginate moves,
               each_serializer: ::V2::MoveSerializer,
               include: included_relationships,
               fields: ::V2::MoveSerializer::INCLUDED_FIELDS
    end

    def show_and_render
      render_move(move, :ok)
    end

    def create_and_render
      move = Move.new(move_attributes)
      authorize!(:create, move)
      move.save!

      Notifier.prepare_notifications(topic: move, action_name: 'create')

      render_move(move, :created)
    end

    def update_and_render
      move.assign_attributes(common_move_attributes)
      action_name = move.status_changed? ? 'update_status' : 'update'
      move.save!
      move.allocation&.refresh_status_and_moves_count!

      Allocations::CreateInNomis.call(move) if create_in_nomis?
      Notifier.prepare_notifications(topic: move, action_name: action_name)

      render_move(move, :ok)
    end

  private

    PERMITTED_MOVE_PARAMS = [
      :type,
      attributes: %i[
        date
        time_due
        status
        additional_information
        cancellation_reason
        cancellation_reason_comment
        reason_comment
        move_agreed
        move_agreed_by
        move_type
        date_from
        date_to
      ],
      relationships: {},
    ].freeze

    def create_in_nomis?
      move.allocation_id? && params[:create_in_nomis].to_s == 'true'
    end

    def move_params
      @move_params ||= params.require(:data).permit(PERMITTED_MOVE_PARAMS).to_h
    end

    def move_attributes
      common_move_attributes.tap do |attributes|
        attributes[:supplier] = SupplierChooser.new(doorkeeper_application_owner, from_location).call unless from_location_attributes.nil?
        attributes[:from_location] = from_location unless from_location_attributes.nil?
        attributes[:to_location] = to_location unless to_location_attributes.nil?
        attributes[:version] = 2
      end
    end

    def common_move_attributes
      move_params[:attributes].tap do |attributes|
        attributes[:profile] = profile unless profile_attributes.nil?
        attributes[:court_hearings] = court_hearings unless court_hearing_attributes.nil?
        attributes[:prison_transfer_reason] = prison_transfer_reason unless prison_transfer_reason_attributes.nil?
      end
    end

    def profile
      profile_id = profile_attributes.dig(:data, :id)

      Profile.find(profile_id) if profile_id
    end

    def from_location
      @from_location ||=
        begin
          location_id = from_location_attributes.dig(:data, :id)
          Location.find(location_id) if location_id
        end
    end

    def to_location
      location_id = move_params.dig(:relationships, :to_location, :data, :id)

      Location.find(location_id) if location_id
    end

    def court_hearings
      court_hearing_ids = court_hearing_attributes.dig(:data)
      court_hearing_ids = court_hearing_ids&.map { |court_hearing| court_hearing[:id] }

      CourtHearing.where(id: court_hearing_ids) if court_hearing_ids
    end

    def prison_transfer_reason
      prison_transfer_reason_id = prison_transfer_reason_attributes.dig(:data, :id)

      PrisonTransferReason.find_by(id: prison_transfer_reason_id) if prison_transfer_reason_id
    end

    def profile_attributes
      move_params.dig(:relationships, :profile)
    end

    def from_location_attributes
      move_params.dig(:relationships, :from_location)
    end

    def to_location_attributes
      move_params.dig(:relationships, :to_location)
    end

    def court_hearing_attributes
      move_params.dig(:relationships, :court_hearings)
    end

    def prison_transfer_reason_attributes
      move_params.dig(:relationships, :prison_transfer_reason)
    end

    def render_move(move, status)
      render serializer: ::V2::MoveSerializer,
             json: move,
             status: status,
             include: included_relationships,
             fields: ::V2::MoveSerializer::INCLUDED_FIELDS
    end

    def move
      @move ||= Move
        .accessible_by(current_ability)
        .includes(
          :from_location, :to_location, profile: { person: %i[gender ethnicity], person_escort_record: { framework_flags: :framework_question } }
        )
        .find(params[:id])
    end

    def included_relationships
      IncludeParamHandler.new(params).call
    end

    def supported_relationships
      ::V2::MoveSerializer::SUPPORTED_RELATIONSHIPS
    end
  end
end
