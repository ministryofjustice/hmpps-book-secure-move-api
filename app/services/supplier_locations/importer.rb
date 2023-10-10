# frozen_string_literal: true

module SupplierLocations
  class Importer
    DATE_FORMAT = '%Y-%m-%d'

    attr_accessor :filename

    def initialize(filename)
      self.filename = filename
    end

    def call
      message("Updating supplier locations from #{filename}")
      validate_file!

      message("Updating locations for #{suppliers.size} suppliers, effective from #{effective_from || 'the dawn of time'} to #{effective_to || 'forever and ever'}")

      suppliers.each do |supplier_name, codes|
        supplier = Supplier.find_by!(key: supplier_name)
        locations = codes.collect { |code| Location.find_by(nomis_agency_id: code) }.compact

        message("Updating #{locations.size} locations for supplier #{supplier.name}...")
        SupplierLocation.link_locations(effective_from:, effective_to:, supplier:, locations:)
      end

      message('Done.')
    end

  private

    def yaml
      @yaml ||= ActiveSupport::HashWithIndifferentAccess.new(YAML.safe_load(File.read(filename)))
    end

    def suppliers
      @suppliers ||= yaml[:suppliers]
    end

    def effective_from
      @effective_from ||= yaml[:effective_from].presence && Date.strptime(yaml[:effective_from], DATE_FORMAT)
    end

    def effective_to
      @effective_to ||= yaml[:effective_to].presence && Date.strptime(yaml[:effective_to], DATE_FORMAT)
    end

    def validate_file!
      raise "Invalid dates in file: effective_from or effective_to (or both) must be present and in format 'YYYY-MM-DD'" if effective_from.blank? && effective_to.blank?
      raise 'No suppliers found in file' if suppliers.blank?
    end

    def message(text)
      puts text unless Rails.env.test? # rubocop:disable Rails/Output
    end
  end
end
