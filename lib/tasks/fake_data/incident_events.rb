module Tasks
  module FakeData
    class IncidentEvents
      attr_reader :move

      def initialize(move)
        @move = move
      end

      def call
        event_count = rand(1..5)
        event_count.times do
          random_event.create!(
            eventable: move,
            occurred_at: Time.zone.now,
            recorded_at: Time.zone.now,
            details: {
              reported_at: Time.zone.now,
              location_id: move.to_location_id,
              supplier_personnel_numbers: [12_345, 54_321],
              vehicle_reg: 'C63 AMG',
              fault_classification: 'investigation',
              fake: true,
            },
            supplier: random_supplier,
            notes: 'Created from fake data',
          )
        end

        puts "Added #{event_count} incident events to Move #{move.id}"
      end

    private

      def suppliers
        @suppliers ||= Supplier.all.to_a
      end

      def random_supplier
        suppliers.sample
      end

      def random_event
        [
          GenericEvent::PersonMoveRoadTrafficAccident,
          GenericEvent::PersonMovePersonEscaped,
          GenericEvent::PersonMoveUsedForce,
          GenericEvent::PersonMoveMajorIncidentOther,
          GenericEvent::PersonMoveSeriousInjury,
          GenericEvent::PersonMoveMinorIncidentOther,
          GenericEvent::PersonMoveDeathInCustody,
          GenericEvent::PersonMoveAssault,
          GenericEvent::PersonMovePersonEscapedKpi,
          GenericEvent::PersonMoveReleasedError,
        ].sample
      end
    end
  end
end
