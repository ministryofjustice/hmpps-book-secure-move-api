# frozen_string_literal: true

module Moves
  class Updater
    attr_accessor :move_params, :move, :status_changed, :date_changed

    def initialize(move, move_params)
      self.move = move
      self.move_params = move_params
    end

    def call
      update_move_status
      move.assign_attributes(attributes)

      # NB: rather than update directly, we need to detect whether the move status has changed before saving the record
      self.status_changed = move.status_changed?
      self.date_changed = move.date_changed?

      move.transaction do
        move.save!
        move.allocation&.refresh_status_and_moves_count!
      end
    end

  private

    def document_attributes
      @document_attributes ||= move_params.dig(:relationships, :documents, :data)
    end

    def person_attributes
      move_params.dig(:relationships, :person)
    end

    def profile_attributes
      move_params.dig(:relationships, :profile)
    end

    def document_ids
      document_attributes.map { |doc| doc[:id] }
    end

    # 1. Frontend specifies empty docs: update documents to be empty
    # 2. Frontend does not include document relationship: don't update documents at all
    # 3. Frontend specifies empty person: update person to be nil
    # 4. Frontend does not include person relationship: don't update person at all
    def attributes
      attributes = move_params.fetch(:attributes, {})

      # TODO: to be removed once move profile migration complete
      if person_attributes.present? && profile_attributes.nil?
        person = Person.find_by(id: person_attributes.dig(:data, :id))
        attributes[:profile] = person&.latest_profile
      end

      attributes[:profile] = Profile.find_by(id: profile_attributes.dig(:data, :id)) if profile_attributes.present?

      profile = attributes[:profile] || move.profile
      profile.documents = Document.where(id: document_ids) unless document_attributes.nil?

      attributes
    end

    def update_move_status
      # NB: for historic reasons it is still possible for a client to manually update a move's status (without an associated event).
      # If the client is attempting to update a move's status, compare the before and after status to infer the correct
      # state transition and apply that via the move's state machine.

      new_status = attributes.delete(:status)
      raise ActiveRecord::RecordInvalid if new_status.present? && !Move.statuses.keys.include?(new_status)

      transition = { move.status => new_status }
      case transition
      when { Move::MOVE_STATUS_PROPOSED => Move::MOVE_STATUS_REQUESTED }
        move.approve
      when { Move::MOVE_STATUS_REQUESTED => Move::MOVE_STATUS_BOOKED }
        move.accept
      when { Move::MOVE_STATUS_BOOKED => Move::MOVE_STATUS_IN_TRANSIT }
        move.start
      when { Move::MOVE_STATUS_IN_TRANSIT => Move::MOVE_STATUS_COMPLETED }
        move.complete
      when { Move::MOVE_STATUS_PROPOSED => Move::MOVE_STATUS_CANCELLED }
        move.reject
      when { Move::MOVE_STATUS_REQUESTED => Move::MOVE_STATUS_CANCELLED }
        move.reject
      when { Move::MOVE_STATUS_BOOKED => Move::MOVE_STATUS_CANCELLED }
        move.cancel # FIXME: ADD PARAMS
      end
    end
  end
end
