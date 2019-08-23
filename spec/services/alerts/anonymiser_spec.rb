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
        dateCreated: '2001-09-28',
        expired: false,
        active: true,
        addedByFirstName: 'PAMMY-BARBARA',
        addedByLastName: 'SUMMERBURGER',
        expiredByFirstName: 'GLENNA',
        expiredByLastName: 'FLATLEY',
        dateExpires: '2006-12-26'
      },
      {
        alertId: 2,
        alertType: 'X',
        alertTypeDescription: 'Security',
        alertCode: 'XEL',
        alertCodeDescription: 'Escape List',
        comment: 'some more personal details',
        dateCreated: '2001-11-14',
        expired: false,
        active: true,
        addedByFirstName: 'BILLY-BOB',
        addedByLastName: 'GREYGARDINER',
        expiredByFirstName: 'TOMMY',
        expiredByLastName: 'POLLICH',
        dateExpires: '2008-02-06'
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

    it 'resets first name' do
      expect(anonymised[:addedByFirstName]).not_to eql 'PAMMY-BARBARA'
    end

    it 'resets last name' do
      expect(anonymised[:addedByLastName]).not_to eql 'SUMMERBURGER'
    end

    it 'resets created date' do
      expect(anonymised[:dateCreated]).not_to eql '2001-11-14'
    end

    it 'resets expires date' do
      expect(anonymised[:dateCreated]).not_to eql '2008-02-06'
    end
  end
end
