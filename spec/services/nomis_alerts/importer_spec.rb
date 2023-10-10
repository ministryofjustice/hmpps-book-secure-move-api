# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisAlerts::Importer do
  subject(:importer) { described_class.new(alert_codes:) }

  let(:alert_types) do
    [
      {
        parent_code: nil,
        code: 'R',
        description: 'Risk',
        domain: 'ALERT',
        parent_domain: nil,
        active_flag: 'Y',
      },
      {
        parent_code: nil,
        code: 'S',
        description: 'Security',
        domain: 'ALERT',
        parent_domain: nil,
        active_flag: 'Y',
      },
    ]
  end

  let(:alert_codes) do
    [
      {
        parent_code: 'R',
        code: 'RDP',
        description: 'Risk to people',
        domain: 'ALERT_CODE',
        parent_domain: 'ALERT',
        active_flag: 'Y',
      },
      {
        parent_code: 'R',
        code: 'RDA',
        description: 'Risk to animals',
        domain: 'ALERT_CODE',
        parent_domain: 'ALERT',
        active_flag: 'Y',
      },
    ]
  end

  before do
    allow(NomisClient::AlertTypes).to receive(:get).and_return(alert_types)
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(NomisAlert, :count).by(2)
    end

    it 'creates `Risk to People`' do
      importer.call
      expect(NomisAlert.find_by(code: 'RDP')).to be_present
    end

    it 'creates `Risk to Animals`' do
      importer.call
      expect(NomisAlert.find_by(code: 'RDA')).to be_present
    end
  end

  context 'with one existing record' do
    before do
      NomisAlert.create!(
        code: 'RDP',
        type_code: 'R',
        description: 'Risk to people',
        type_description: 'Risk',
      )
    end

    it 'creates only the missing item' do
      expect { importer.call }.to change(NomisAlert, :count).by(1)
    end
  end

  context 'with one existing record with the wrong description' do
    let!(:risk) do
      NomisAlert.create!(
        code: 'RDP',
        type_code: 'R',
        description: 'Risk to humans',
        type_description: 'Risky',
      )
    end

    it 'updates the description of the existing record' do
      importer.call
      expect(risk.reload.description).to eq 'Risk to people'
    end

    it 'updates the type_description of the existing record' do
      importer.call
      expect(risk.reload.type_description).to eq 'Risk'
    end
  end

  context 'with a valid assessment assessment_question mapping' do
    let!(:hold_separately_question) do
      create :assessment_question, key: :hold_separately
    end

    it 'updates the assessment question mapping for a known question key' do
      importer.call
      expect(NomisAlert.find_by(code: 'RDP').assessment_question_id).to eq hold_separately_question.id
    end

    it 'ignores the assessment question mapping for an unknown question key' do
      importer.call
      expect(NomisAlert.find_by(code: 'RDA').assessment_question_id).to be_nil
    end
  end
end
