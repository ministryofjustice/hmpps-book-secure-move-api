# frozen_string_literal: true

RSpec.shared_context 'with Nomis alerts reference data' do
  let(:serco_supplier) { create :supplier, key: 'serco', name: 'Serco' }

  before do
    # Seed the database with nomis-sourced data for genders, ethnicities, alerts, identifiers, assessment questions
    Ethnicities::Importer.new(NomisClient::Ethnicities.get).call
    Genders::Importer.new(NomisClient::Genders.get).call
    IdentifierTypes::Importer.new.call
    AssessmentQuestions::Importer.new.call
    # NomisAlerts::Importer.new.call
  end
end
