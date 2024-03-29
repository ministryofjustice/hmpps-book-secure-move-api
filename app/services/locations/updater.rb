# frozen_string_literal: true

module Locations
  class Updater
    YOI_NOMIS_AGENCIES = %w[WYI WNI CKI PYI FMI FYI].freeze

    def self.call
      Location.transaction do
        Location.update_all(young_offender_institution: false)
        Location.where(nomis_agency_id: YOI_NOMIS_AGENCIES).update_all(young_offender_institution: true)
      end
    end
  end
end
