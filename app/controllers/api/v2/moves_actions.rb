module Api::V2
  module MovesActions
    def index_and_render
      paginate moves, serializer: ::V2::MovesSerializer, include: included_relationships, fields: ::V2::MovesSerializer::INCLUDED_FIELDS do |_, options|
        options[:params] = {
          vehicle_registration: meta_fields.include?('vehicle_registration'),
          expected_time_of_arrival: meta_fields.include?('expected_time_of_arrival'),
          expected_collection_time: meta_fields.include?('expected_collection_time'),
        }
      end
    end

    def show_and_render
      render_move(move, :ok)
    end

    def create_and_render
      log_with_request(:info, 'V2 Move creation started')
      validate_move_status
      move = Move.new(move_attributes)
      move.supplier = doorkeeper_application_owner || SupplierChooser.new(move).call

      authorize!(:create, move)
      move.save!

      log_with_request(:info, "Move saved with reference [#{move.reference}] - status [#{move.status}]")

      Notifier.prepare_notifications(topic: move, action_name: 'create')

      create_automatic_event!(eventable: move, event_class: GenericEvent::MoveProposed) if move.proposed?
      create_automatic_event!(eventable: move, event_class: GenericEvent::MoveRequested) if move.requested?

      UpdateMoveNomisDataJob.perform_later(move_id: move.id)

      PrometheusMetrics.instance.record_move_count

      log_with_request(:info, "V2 Move creation finished - #{move.reference}")

      render_move(move, :created)
    end

    def update_and_render
      move.present? # verify the move exists before validations
      new_status = validate_move_status
      if new_status.present?
        move.infer_status_transition(
          new_status,
          rejection_reason: common_move_attributes.delete(:rejection_reason),
          cancellation_reason: common_move_attributes.delete(:cancellation_reason),
          cancellation_reason_comment: common_move_attributes.delete(:cancellation_reason_comment),
          date: common_move_attributes[:date],
        )
      end
      move.assign_attributes(common_move_attributes)
      action_name = move.status_changed? ? 'update_status' : 'update'
      move_date_changed = move.date_changed?
      move.save!

      if move_date_changed
        create_automatic_event!(
          eventable: move,
          event_class: GenericEvent::MoveDateChanged,
          details: { date: move.date.iso8601, date_changed_reason: move.date_changed_reason },
        )
      end

      move.allocation&.refresh_status_and_moves_count!

      Allocations::CreateInNomis.call(move) if create_in_nomis?
      Notifier.prepare_notifications(topic: move, action_name:)

      render_move(move, :ok)
    end

  private

    PERMITTED_MOVE_PARAMS = [
      :type,
      { attributes: %i[
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
          recall_date
          date_changed_reason
        ],
        relationships: {} },
    ].freeze

    def create_in_nomis?
      move.allocation_id? && params[:create_in_nomis].to_s == 'true'
    end

    def move_params
      @move_params ||= params.require(:data).permit(PERMITTED_MOVE_PARAMS).to_h
    end

    def move_attributes
      common_move_attributes.tap do |attributes|
        attributes[:from_location] = from_location unless from_location_attributes.nil?
        attributes[:to_location] = to_location unless to_location_attributes.nil?
        attributes[:version] = 2
      end
    end

    def common_move_attributes
      move_params.fetch(:attributes, {}).tap do |attributes|
        attributes[:profile] = profile unless profile_attributes.nil?
        attributes[:court_hearings] = court_hearings unless court_hearing_attributes.nil?
        attributes[:prison_transfer_reason] = prison_transfer_reason unless prison_transfer_reason_attributes.nil?
      end
    end

    def validate_move_status
      status = move_params.fetch(:attributes, {})[:status]
      log_with_request(:debug, "Validating current status of move - [#{status}]")
      if status.present?
        validator = Moves::StatusValidator.new(status:, cancellation_reason: move_params.fetch(:attributes, {})[:cancellation_reason], rejection_reason: move_params.fetch(:attributes, {})[:rejection_reason])
        valid = validator.valid?
        log_with_request(:debug, "Valid Move status: - [#{valid}]")
        raise ActiveModel::ValidationError, validator unless valid
      end
      status
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
      court_hearing_ids = court_hearing_attributes[:data]
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
      render_json move, serializer: ::V2::MoveSerializer, include: included_relationships, fields: ::V2::MoveSerializer::INCLUDED_FIELDS, status:
    end

    def move
      @move ||= Move
        .accessible_by(current_ability)
        .includes(active_record_relationships)
        .find(params[:id])
    end

    def supported_relationships
      # for performance reasons, we support fewer include relationships on the index action
      if action_name == 'index'
        ::V2::MovesSerializer::SUPPORTED_RELATIONSHIPS
      else
        ::V2::MoveSerializer::SUPPORTED_RELATIONSHIPS
      end
    end
  end
end
