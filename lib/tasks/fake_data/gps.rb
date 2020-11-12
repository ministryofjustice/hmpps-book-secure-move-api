require_relative 'city.rb'
module Tasks
  module FakeData
    class GPS
      attr_reader :journey, :move, :max_distance, :origin, :destination

      RAD_PER_DEG = Math::PI / 180
      EARTH_RADIUS = 6371 # in km

      def initialize(cities, journey, max_distance)
        @journey = journey
        @move = journey.move
        @cities = cities
        @origin = cities.sample
        @destination = random_destination_city(@origin, max_distance)
      end

      def call(steps)
        puts "@origin: #{@origin}"
        puts "@destination: #{@destination}"
        puts "@distance: #{distance(@origin, @destination)}"

        data = random_path(steps)

        puts data.to_json
      end

    private

      def random_path(steps)
        vehicle_id = journey&.vehicle&.key?('id') ? journey.vehicle['id'] : rand(99999).to_s
        vehicle_registration = journey&.vehicle&.key?('registration') ? journey.vehicle['registration'] : "REG-#{vehicle_id}"
        vehicle_vin = ["VIN-#{vehicle_id}", nil].sample # NB VIN is optional, so could be nil

        (0..steps).map do |step|
          pt = {
              id: SecureRandom.uuid,
              move_id: move.id,
              journey_id: journey.id,
              timestamp: journey.client_timestamp + step.minutes + rand(-10..10).seconds,
              vehicle_id: vehicle_id,
              vehicle_registration: vehicle_registration,
              vehicle_vin: vehicle_vin,
              altitude: [(rand()*100).round(1), nil].sample,
              hdop: [(rand()*20).round(1), nil].sample,
              vdop: [(rand()*20).round(1), nil].sample,
              heading: [rand(360), nil].sample,
              speed: (rand()*100).round(1)
          }.merge(random_waypoint(steps, step)).compact
        end
      end



      def random_destination_city(origin, max_distance)
        @cities.shuffle.find{|city| origin != city && distance(origin, city) <= max_distance }
      end

      def distance(place1, place2)
        # Based on Haversine formula, https://stackoverflow.com/questions/12966638/how-to-calculate-the-distance-between-two-gps-coordinates-without-using-google-m
        lat1_rad, lat2_rad = degrees_to_radians(place1[:latitude]), degrees_to_radians(place2[:latitude])
        lon1_rad, lon2_rad = degrees_to_radians(place1[:longitude]), degrees_to_radians(place2[:longitude])

        a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
        c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

        EARTH_RADIUS * c # Delta in km
      end

      def random_waypoint(steps, step)
        # Based on Geo-midpoint calculations, http://www.geomidpoint.com/calculation.html

        origin_lat_r = degrees_to_radians(origin[:latitude])
        origin_lng_r = degrees_to_radians(origin[:longitude])
        origin_x = x(origin_lat_r, origin_lng_r)
        origin_y = y(origin_lat_r, origin_lng_r)
        origin_z = z(origin_lat_r)

        destination_lat_r = degrees_to_radians(destination[:latitude])
        destination_lng_r = degrees_to_radians(destination[:longitude])
        destination_x = x(destination_lat_r, destination_lng_r)
        destination_y = y(destination_lat_r, destination_lng_r)
        destination_z = z(destination_lat_r)

        fraction = 1.0 * step / steps

        # generate a bit of random error which is maximal at the midpoint of the journey and no bigger than the 1.5 * step size
        err = Math.sqrt((destination_x - origin_x) ** 2 + (destination_y - origin_y) ** 2 + (destination_z - origin_z) ** 2) * 1.5 * Math.sin(fraction * Math::PI) * rand(-1.0..1.0) / steps

        waypoint_x = (origin_x + (destination_x - origin_x) * fraction) + err
        waypoint_y = (origin_y + (destination_y - origin_y) * fraction) + err
        waypoint_z = (origin_z + (destination_z - origin_z) * fraction) # no error in Z as we do not want to be flying/tunnelling

        longitude_r = Math.atan2(waypoint_y, waypoint_x)
        hyp = Math.sqrt(waypoint_x ** 2 + waypoint_y ** 2)
        latitude_r = Math.atan2(waypoint_z, hyp)

        { latitude: latitude_r / RAD_PER_DEG, longitude: longitude_r / RAD_PER_DEG }
      end

      def degrees_to_radians(deg)
        deg * RAD_PER_DEG
      end

      def x(latitude_r, longitude_r)
        Math.cos(latitude_r) * Math.cos(longitude_r)
      end

      def y(latitude_r, longitude_r)
        Math.cos(latitude_r) * Math.sin(longitude_r)
      end

      def z(latitude_r)
        Math.sin(latitude_r)
      end
    end
  end
end
