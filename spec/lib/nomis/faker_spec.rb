# frozen_string_literal: true

require 'rails_helper'
require 'nomis/faker'

RSpec.describe Nomis::Faker do
  describe '#nomis_offender_number' do
    it 'generates a random offender number with the correct format' do
      expect(described_class.nomis_offender_number).to match(/^\w\d{4}\w{2}$/)
    end
  end

  describe '#pnc_number' do
    it 'generates a random PNC number with the correct format' do
      expect(described_class.pnc_number).to match %r[^\d{2}/\d{6}\w$]
    end
  end

  describe '#cro_number' do
    it 'generates a random CRO number with the correct format' do
      expect(described_class.cro_number).to match %r[^\d{5}/\d{2}\w$]
    end
  end
end
