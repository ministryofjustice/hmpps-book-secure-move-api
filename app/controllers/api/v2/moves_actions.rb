module Api::V2
  module MovesActions
    def index_and_render
      moves = Moves::Finder.new(filter_params, current_ability, params[:sort] || {}).call

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
      raise ActiveRecord::ReadOnlyRecord, "Can't change moves coming from Nomis" if move.from_nomis?

      @move.assign_attributes(move_attributes)
      @move.save!
      @move.allocation&.refresh_status_and_moves_count!

      action_name = @move.status_changed? ? 'update_status' : 'update'
      Notifier.prepare_notifications(topic: @move, action_name: action_name)

      render_move(@move, :ok)
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

    def move_params
      @move_params ||= params.require(:data).permit(PERMITTED_MOVE_PARAMS).to_h
    end

    def move_attributes
      move_params[:attributes].tap do |attributes|
        attributes[:profile] = profile unless profile.nil?
        attributes[:from_location] = from_location unless from_location.nil?
        attributes[:to_location] = to_location unless to_location.nil?
        attributes[:court_hearings] = court_hearings unless court_hearings.nil?
        attributes[:prison_transfer_reason] = prison_transfer_reason unless prison_transfer_reason.nil?
      end
    end

    def profile
      profile_id = move_params.dig(:relationships, :profile, :data, :id)

      Profile.find(profile_id) if profile_id
    end

    def from_location
      location_id = move_params.dig(:relationships, :from_location, :data, :id)

      Location.find(location_id) if location_id
    end

    def to_location
      location_id = move_params.dig(:relationships, :to_location, :data, :id)

      Location.find(location_id) if location_id
    end

    def court_hearings
      court_hearing_ids = move_params.dig(:relationships, :court_hearings, :data)
      court_hearing_ids = court_hearing_ids&.map { |court_hearing| court_hearing[:id] }

      CourtHearing.where(id: court_hearing_ids) unless court_hearing_ids.nil?
    end

    def prison_transfer_reason
      prison_transfer_reason_id = move_params.dig(:relationships, :prison_transfer_reason, :data, :id)

      PrisonTransferReason.find_by(id: prison_transfer_reason_id) if prison_transfer_reason_id
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
        .includes(:from_location, :to_location, profile: { person: %i[gender ethnicity] })
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
