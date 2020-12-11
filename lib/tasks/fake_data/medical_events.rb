module Tasks
  module FakeData
    class MedicalEvents
      attr_reader :per, :move

      def initialize(per)
        @per = per
        @move = per.move
      end

      def call
        GenericEvent::PerMedicalAid.create!(
          eventable: per,
          occurred_at: Time.zone.now,
          recorded_at: Time.zone.now,
          details: {
            advised_at: Time.zone.now,
            advised_by: 'Dr. Bunsen',
            treated_at: Time.zone.now,
            treated_by: 'Beaker',
            location_id: move.from_location_id,
            supplier_personnel_number: 12_345,
            fake: true,
          },
          supplier: random_supplier,
          notes: 'Created from fake data',
        )

        puts "Added a medical event to Person Escort Record #{per.id}, part of Move #{per.move_id}"
      end

    private

      def suppliers
        @suppliers ||= Supplier.all.to_a
      end

      def random_supplier
        suppliers.sample
      end
    end
  end
end
