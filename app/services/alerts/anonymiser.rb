# frozen_string_literal: true

module Alerts
  class Anonymiser
    attr_accessor :nomis_offender_number, :alerts

    def initialize(nomis_offender_number:, alerts:)
      self.nomis_offender_number = nomis_offender_number
      self.alerts = alerts
    end

    def call
      alerts.map do |alert|
        alert.merge(
          addedByFirstName: Faker::Name.first_name.upcase,
          addedByLastName: Faker::Name.last_name.upcase,
          expiredByFirstName: Faker::Name.first_name.upcase,
          expiredByLastName: Faker::Name.last_name.upcase,
          dateCreated: Faker::Date.between(10.years.ago, 6.years.ago).iso8601,
          dateExpires: Faker::Date.between(5.years.ago, 1.years.ago).iso8601,
          comment: ''
        ).with_indifferent_access
      end
    end
  end
end
