# frozen_string_literal: true

RSpec.shared_context 'Nomis alerts reference data' do
  before do
    # Seed the database with nomis-sourced data for genders, ethnicities, alerts, identifiers, assessment questions
    Ethnicities::Importer.new(NomisClient::Ethnicities.get).call
    Genders::Importer.new(NomisClient::Genders.get).call
    IdentifierTypes::Importer.new.call
    AssessmentQuestions::Importer.new.call
    NomisAlerts::Importer.new(alert_codes: NomisClient::AlertCodes.get).call
  end
end
