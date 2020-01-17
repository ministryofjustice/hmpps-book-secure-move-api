# frozen_string_literal: true

module Alerts
  class Anonymiser
    attr_accessor :nomis_offender_number, :alerts

    def initialize(nomis_offender_number:, alerts:)
      self.nomis_offender_number = nomis_offender_number
      self.alerts = alerts
    end

    def call
      alerts.map { |alert| anonymise_alert(alert) }
    end

    private

    def anonymise_alert(alert)
      alert.merge(
        addedByFirstName: Faker::Name.first_name.upcase,
        addedByLastName: Faker::Name.last_name.upcase,
        expiredByFirstName: Faker::Name.first_name.upcase,
        expiredByLastName: Faker::Name.last_name.upcase,
        dateCreated: fake_date_created,
        dateExpires: fake_date_expires,
        comment: nil,
      ).with_indifferent_access
    end

    def fake_date_created
      Faker::Date.between(from: 10.years.ago, to: 6.years.ago).iso8601
    end

    def fake_date_expires
      Faker::Date.between(from: 5.years.ago, to: 1.year.ago).iso8601
    end
  end
end
