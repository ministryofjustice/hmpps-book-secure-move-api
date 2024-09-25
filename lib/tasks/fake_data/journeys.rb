module Tasks
  module FakeData
    class Journeys
      attr_reader :move, :from_location, :to_location, :supplier, :vehicle

      def initialize(move)
        @move = move
        @from_location = move.from_location
        @to_location = move.to_location || Location.order('RANDOM()').where(location_type: 'prison').first # pick a random prison if to_location was not specified
        @supplier = move.from_location.suppliers.first || Supplier.all.sample # pick a supplier based on the from location or at random
        @vehicle = {
          "id": rand(1..9999).to_s,
          "registration": "#{('A'..'Z').to_a.sample(3).join}-#{rand(1..100)}",
          "fake": true,
        }
      end

      # Creates some random journeys between A and B
      def call(number_of_journeys = rand(1..5))
        current_location = from_location
        journey_counter = 1
        timestamp = move.date + rand(5..10).hours

        if number_of_journeys > 1
          intermediate_location = random_location(current_location)
          create_journey(timestamp, current_location, intermediate_location, true)
          timestamp += rand(30..90).minutes
          current_location = intermediate_location
          journey_counter += 1
        end

        while journey_counter < number_of_journeys
          # make some intermediate journeys which might or might not be billable
          intermediate_location = random_location(current_location)
          create_initial_move_event(timestamp, intermediate_location)

          # randomly create some events with intermediate journeys
          case random_event # add some random events to the journeys
          when :redirect_move_billable # billable redirect move (not journey) to intermediate_location, e.g. "PMU requested redirect whilst en route"
            create_redirect_move_event(timestamp, intermediate_location)

            # billable journey for redirection to intermediate_location
            create_journey(timestamp, current_location, intermediate_location, true)

            # subsequent redirect event back to to_location to make sure events remain consistent with move record; no journey record is required
            timestamp += rand(30..90).minutes
            create_redirect_move_event(timestamp, to_location)
          else
            # 50% chance of a conventional intermediate journey
            create_journey(timestamp, current_location, intermediate_location, true)
          end

          journey_counter += 1
          timestamp += rand(30..90).minutes
        end

        # final journey
        create_journey(timestamp, current_location, to_location, true)
      end

    private

      def random_location(current_location)
        Location.where.not(id: [@from_location.id, current_location.id, @to_location.id]).order(Arel.sql('RANDOM()')).first
      end

      def create_journey(timestamp, journey_from, journey_to, billable)
        move.journeys.create!(
          client_timestamp: timestamp,
          from_location: journey_from,
          to_location: journey_to,
          supplier:,
          state: 'completed',
          billable:,
          vehicle:,
        )
      end

      def create_initial_move_event(timestamp, _location)
        initial_transition_events = [GenericEvent::MoveProposed, GenericEvent::MoveRequested]
        initial_transition_events.sample.create!(
          eventable: move,
          occurred_at: timestamp,
          created_by: 'TEST_USER',
          recorded_at: timestamp,
          notes: 'Created from fake data',
          details: { fake: true },
          supplier_id: supplier.id,
        )
      end

      def create_redirect_move_event(timestamp, location)
        GenericEvent::MoveRedirect.create!(
          eventable: move,
          occurred_at: timestamp,
          created_by: 'TEST_USER',
          recorded_at: timestamp,
          notes: 'Created from fake data',
          details: {
            fake: true,
            to_location_id: location.id,
            reason: GenericEvent::MoveRedirect.reasons.keys.sample,
            move_type: random_move_type(move.from_location, location),
          },
          supplier_id: supplier.id,
        )
      end

      def random_move_type(from_location, to_location)
        if from_location.police? && to_location.police?
          'police_transfer'
        elsif from_location.police? && to_location.detained?
          %w[prison_recall video_remand].sample
        elsif from_location.police? && to_location.court?
          'court_appearance'
        elsif from_location.court? && to_location.detained?
          'prison_remand'
        elsif from_location.court? && to_location.not_detained?
          'court_other'
        elsif from_location.detained? && to_location.detained?
          'prison_transfer'
        elsif from_location.detained? && to_location.court?
          'court_appearance'
        elsif to_location.hospital?
          'hospital'
        else
          'approved_premises'
        end
      end

      def random_event
        case rand(1..2)
        when 1
          :redirect_move_billable
        end
      end
    end
  end
end
