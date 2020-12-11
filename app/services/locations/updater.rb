# frozen_string_literal: true

module Locations
  class Updater
    YOI_NOMIS_AGENCIES = %w[WYI WNI CKI PRI FMI].freeze

    def self.call
      Location.update_all(yoi: false)
      Location.where(nomis_agency_id: YOI_NOMIS_AGENCIES).update_all(yoi: true)
    end
  end
end
