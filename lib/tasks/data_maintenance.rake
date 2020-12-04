# frozen_string_literal: true

namespace :data_maintenance do
  desc 'remove duplicated moves'
  task remove_duplicate_moves: :environment do
    duplicates = Move
                 .select(:from_location_id, :to_location_id, :person_id, :date)
                 .group(:from_location_id, :to_location_id, :person_id, :date)
                 .having('COUNT(*) > 1').size

    duplicates.each_pair do |k, _|
      next if k.nil? && !Location.find(k[0]).prison?

      moves = Move
              .order(:created_at)
              .where(from_location_id: k[0], to_location_id: k[1], person_id: k[2], date: k[3])
              .offset(1)
      moves.destroy_all
    end
  end

  desc 'fix incorrect move_agreed for all moves except prison transfers'
  task fix_move_agreed_for_non_prison_transfers: :environment do
    Move.where(move_agreed: false).where.not(move_type: 'prison_transfer').update_all(move_agreed: nil)
  end

  desc 'fix nil estate for all existing production allocations data'
  task fix_nil_allocations_estate: :environment do
    Allocation.where(estate: nil).update_all(estate: :adult_male)
  end

  desc 'fix blank (empty string) person references that should be stored as null'
  task fix_blank_person_references: :environment do
    Person.where(nomis_prison_number: '').update_all(nomis_prison_number: nil)
    Person.where(prison_number: '').update_all(prison_number: nil)
    Person.where(criminal_records_office: '').update_all(criminal_records_office: nil)
    Person.where(police_national_computer: '').update_all(police_national_computer: nil)
  end

  desc 'fix generic event classification for existing data'
  task fix_generic_event_classifications: :environment do
    GenericEvent.where(eventable_type: 'GenericEvent::PerMedicalAid').update_all(classification: 'medical')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMoveAssault').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMoveDeathInCustody').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMoveMajorIncidentOther').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMoveMinorIncidentOther').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMovePersonEscapedKpi').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMovePersonEscaped').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMoveReleasedError').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMoveRoadTrafficAccident').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMoveSeriousInjury').update_all(classification: 'incident')
    GenericEvent.where(eventable_type: 'GenericEvent::PersonMoveUsedForce').update_all(classification: 'incident')
  end
end
