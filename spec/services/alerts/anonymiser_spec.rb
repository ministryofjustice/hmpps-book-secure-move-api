# frozen_string_literal: true

require 'rails_helper'
require 'dotenv/load'

RSpec.describe Alerts::Anonymiser do
  subject(:anonymiser) do
    described_class.new(
      nomis_offender_number: nomis_offender_number,
      alerts: alerts
    )
  end

  let(:nomis_offender_number) { 'D1234VG' }
  let(:alerts) do
    [
      {
        alertId: 1,
        alertType: 'X',
        alertTypeDescription: 'Security',
        alertCode: 'XER',
        alertCodeDescription: 'Escape Risk',
        comment: 'some personal details',
        dateCreated: '2011-09-28',
        expired: false,
        active: true,
        addedByFirstName: 'REFUGIO',
        addedByLastName: 'ROGAHN',
        expiredByFirstName: 'GLENNA',
        expiredByLastName: 'FLATLEY',
        dateExpires: '2016-12-26'
      },
      {
        alertId: 2,
        alertType: 'X',
        alertTypeDescription: 'Security',
        alertCode: 'XEL',
        alertCodeDescription: 'Escape List',
        comment: 'some more personal details',
        dateCreated: '2011-11-14',
        expired: false,
        active: true,
        addedByFirstName: 'AUGUSTUS',
        addedByLastName: 'WILLIAMSON',
        expiredByFirstName: 'TOMMY',
        expiredByLastName: 'POLLICH',
        dateExpires: '2018-02-06'
      }
    ]
  end

  describe '.call' do
    let(:anonymised) do
      anonymiser.call.first
    end

    it 'resets comment' do
      expect(anonymised[:comment]).to be_nil
    end

    it 'resets names' do
      expect(anonymised[:addedByFirstName]).not_to eql 'AUGUSTUS'
    end
  end
end
