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
    medical_event_type = 'GenericEvent::PerMedicalAid'
    incident_event_types = [
      'GenericEvent::PersonMoveRoadTrafficAccident',
      'GenericEvent::PersonMovePersonEscaped',
      'GenericEvent::PersonMoveUsedForce',
      'GenericEvent::PersonMoveMajorIncidentOther',
      'GenericEvent::PersonMoveSeriousInjury',
      'GenericEvent::PersonMoveMinorIncidentOther',
      'GenericEvent::PersonMoveDeathInCustody',
      'GenericEvent::PersonMoveAssault',
      'GenericEvent::PersonMovePersonEscapedKpi',
      'GenericEvent::PersonMoveReleasedError',
    ]
    notification_event_types = [
      'GenericEvent::MoveNotifyPremisesOfArrivalIn30Mins',
      'GenericEvent::MoveNotifyPremisesOfEta',
      'GenericEvent::MoveNotifyPremisesOfExpectedCollectionTime',
    ]

    GenericEvent.where(type: medical_event_type).update_all(classification: 'medical')
    GenericEvent.where(type: incident_event_types).update_all(classification: 'incident')
    GenericEvent.where(type: notification_event_types).update_all(classification: 'notification')
  end

  desc 'remove moves and allocations on staging'
  task remove_data_staging: :environment do
    # NB: this task should never run on production or pre-production
    is_not_production = Rails.env.development? || ENV.fetch('HOSTNAME', 'UNKNOWN') =~ /(\-(dev|staging|uat)\-)/i

    if is_not_production
      moves = Move.all
      puts "Number of moves to be deleted: #{moves.count}"
      allocations = Allocation.all
      puts "Number of allocations to be deleted: #{allocations.count}"
      moves.destroy_all
      allocations.destroy_all
    else
      "You are trying to run this on a production-like environment, which is not allowed."
    end
  end
end
