# frozen_string_literal: true

module Moves
  class Updater
    attr_accessor :move_params, :move, :status_changed

    def initialize(move, move_params)
      self.move = move
      self.move_params = move_params
    end

    def call
      move.assign_attributes(attributes)
      # NB: rather than update directly, we need to detect whether the move status has changed before saving the record
      self.status_changed = move.status_changed?

      move.save!
    end

  private

    def document_attributes
      @document_attributes ||= move_params.dig(:relationships, :documents, :data)
    end

    def person_attributes
      move_params.dig(:relationships, :person)
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

      attributes[:documents] = Document.where(id: document_ids) if document_attributes != nil

      if person_attributes != nil
        person = Person.find_by(id: person_attributes.dig(:data, :id))
        attributes[:profile] = person&.latest_profile
      end

      attributes
    end
  end
end
