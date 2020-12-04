require 'active_support/concern'

module AuthoriserValidations
  extend ActiveSupport::Concern

  included do
    enum authorised_by: {
      PMU: 'PMU',
      CDM: 'CDM',
      Other: 'Other',
    }

    validates :authorised_by, inclusion: { in: authorised_bies }, if: -> { authorised_by.present? }
    validates :authorised_at, iso_date_time: true, if: -> { authorised_at.present? }
  end
end
