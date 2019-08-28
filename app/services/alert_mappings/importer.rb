# frozen_string_literal: true

require 'csv'

module AlertMappings
  class Importer
    def call
      csv = CSV.read(Rails.root.join('tmp', 'alerts.csv'))
      values = []
      counter = 0
      csv.each do |line|
        counter += 1
        values << line[3]
        import_alert(line)
      end
      puts values.uniq
      puts counter
    end

    KNOWN_ALERTS = {
      'Self harm' => :self_harm,
      'Must be segregated' => :hold_separately,
      'Violent' => :violent,
      'Escape' => :escape,
      'Not to be released' => :not_for_release,
      'Health and medical' => :health_issue
    }.freeze

    private

    def import_alert(line)
      return unless KNOWN_ALERTS.key?(line[3])

      create_or_update(
        KNOWN_ALERTS[line[3]],
        description: line[0],
        nomis_alert_type: line[1],
        nomis_alert_code: line[2]
      )
    end

    def create_or_update(key, attributes)

    end
  end
end
