require 'active_support/concern'

module AuthoriserValidations
  extend ActiveSupport::Concern

  def authorised_at=(authorised_at)
    details['authorised_at'] = authorised_at
  end

  def authorised_at
    details['authorised_at']
  end

  def authorised_by=(authorised_by)
    details['authorised_by'] = authorised_by
  end

  def authorised_by
    details['authorised_by']
  end

  included do
    enum authorised_by: {
      PMU: 'PMU',
      CDM: 'CDM',
      Other: 'Other',
    }

    validates :authorised_by, inclusion: { in: authorised_bies }, if: -> { authorised_by.present? }
    validates_each :authorised_at, if: -> { authorised_at.present? } do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end
  end
end
