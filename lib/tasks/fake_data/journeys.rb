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
          journey = create_journey(timestamp, current_location, intermediate_location, true)
          timestamp += rand(30..90).minutes
          current_location = intermediate_location
          journey_counter += 1
        end

        while journey_counter < number_of_journeys
          # make some intermediate journeys which might or might not be billable
          intermediate_location = random_location(current_location)

          # randomly create some events with intermediate journeys
          case random_event # add some random events to the journeys
          when :redirect_move_billable # billable redirect move (not journey) to intermediate_location, e.g. "PMU requested redirect whilst en route"
            create_redirect_move_event(
              timestamp,
              ['requested by PMU for operational reasons', 'requested by prison because no space', 'requested by police because of security concerns'].sample,
              intermediate_location,
            )

            # billable journey for redirection to intermediate_location
            journey = create_journey(timestamp, current_location, intermediate_location, true)

            # subsequent redirect event back to to_location to make sure events remain consistent with move record; no journey record is required
            timestamp += rand(30..90).minutes
            create_redirect_move_event(timestamp, 'redirecting back to original destination following earlier redirect', to_location)

            current_location = intermediate_location
          else
            # 50% chance of a conventional intermediate journey
            journey = create_journey(timestamp, current_location, intermediate_location, true)
            current_location = intermediate_location
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
          supplier: supplier,
          state: 'completed',
          billable: billable,
          vehicle: vehicle,
        )
      end

      def create_lockout_journey_event(journey, timestamp, notes, location)
        journey.events.create!(
          event_name: 'lockout',
          client_timestamp: timestamp,
          details: {
            fake: true,
            supplier_id: supplier.id,
            event_params: {
              attributes: {
                notes: notes,
              },
              relationships: {
                from_location: { data: { id: location.id } },
              },
            },
          },
        )
      end

      def create_redirect_move_event(timestamp, notes, location)
        move.move_events.create!(
          event_name: 'redirect',
          client_timestamp: timestamp,
          details: {
            fake: true,
            supplier_id: supplier.id,
            event_params: {
              attributes: {
                notes: notes,
              },
              relationships: {
                to_location: { data: { id: location.id } },
              },
            },
          },
        )
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
