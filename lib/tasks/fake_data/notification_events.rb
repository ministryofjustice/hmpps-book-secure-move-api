module Tasks
  module FakeData
    class NotificationEvents
      attr_reader :move

      def initialize(move)
        @move = move
      end

      def call
        random_event.create!(
          eventable: move,
          occurred_at: Time.zone.now,
          created_by: 'TEST_USER',
          recorded_at: Time.zone.now,
          details: {
            expected_at: Time.zone.now + 2.hours,
          },
          supplier: random_supplier,
          notes: 'Created from fake data',
        )

        puts "Added #{random_event} notification event to Move #{move.id}"
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
          GenericEvent::MoveNotifyPremisesOfEta,
          GenericEvent::MoveNotifyPremisesOfExpectedCollectionTime,
        ].sample
      end
    end
  end
end
