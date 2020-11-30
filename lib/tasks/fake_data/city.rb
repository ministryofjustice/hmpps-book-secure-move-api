require 'csv'

module Tasks
  module FakeData
    class City
      def cities
        @cities ||= CSV.read('./lib/tasks/data/uk_cities.csv', headers: true).map do |city|
          { name: city['city'], latitude: city['lat'].to_f, longitude: city['lng'].to_f }
        end
      end
    end
  end
end
