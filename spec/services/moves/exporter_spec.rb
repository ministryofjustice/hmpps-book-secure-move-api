# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Moves::Exporter do
  subject(:file) { described_class.new(moves).call }

  let(:content) { file.rewind && file.read }
  let(:csv) { CSV.parse(content) }
  let(:header) { csv.first }
  let(:row) { csv.last }

  let(:question) { create(:assessment_question) }
  let(:from_location) { create(:location, title: 'From Location', nomis_agency_id: 'FROM1') }
  let(:to_location) { create(:location, title: 'To Location', nomis_agency_id: 'TO1') }
  let(:person) { create(:person) }
  let!(:move) { create(:move, from_location: from_location, to_location: to_location, person: person) }
  let(:moves) { Move.all }

  it 'includes correct header names' do
    expect(header).to eq(described_class::HEADINGS)
  end

  it 'has correct number of header columns' do
    expect(header.count).to eq(54)
  end

  it 'has correct number of body columns' do
    expect(row.count).to eq(54)
  end

  it 'includes move details' do
    expect(row).to include(move.status, move.reference, move.move_type, move.additional_information)
  end

  it 'includes move timestamps and date' do
    expect(row).to include(move.created_at.iso8601, move.updated_at.iso8601, move.date.strftime('%Y-%m-%d'))
  end

  it 'includes from location details' do
    expect(row).to include(from_location.title, from_location.nomis_agency_id)
  end

  it 'includes to location details' do
    expect(row).to include(to_location.title, to_location.nomis_agency_id)
  end

  it 'includes person details' do
    expect(row).to include(person.police_national_computer, person.prison_number, person.last_name, person.first_names)
  end

  it 'includes person date of birth' do
    expect(row).to include(person.date_of_birth&.strftime('%Y-%m-%d'))
  end

  it 'includes person gender' do
    expect(row).to include(person.gender.title)
  end

  it 'includes ethnicity details' do
    expect(row).to include(person.ethnicity.title, person.ethnicity.key)
  end

  it 'includes FALSE flag and empty comments when no alerts are present' do
    expect(row).to include('false', '')
  end

  %w[violent escape hold_separately self_harm concealed_items other_risks special_diet_or_allergy health_issue medication wheelchair pregnant other_health solicitor interpreter other_court not_to_be_released special_vehicle].each do |alert_type|
    it "includes TRUE flag and comments when #{alert_type} is present" do
      question.update(key: alert_type)
      move.profile.update(assessment_answers: [{ assessment_question_id: question.id, comments: 'Yikes!' }])
      expect(row).to include('true', 'Yikes!')
    end
  end

  it 'includes description prefix on comments for Nomis alerts' do
    question.update(key: 'violent')
    move.profile.update(assessment_answers: [{ nomis_alert_description: 'Foo', assessment_question_id: question.id, comments: 'Yikes!' }])
    expect(row).to include('Foo: Yikes!')
  end

  it 'includes multiple comment lines for multiple alerts for the same question' do
    question.update(key: 'violent')
    move.profile.update(assessment_answers: [{ assessment_question_id: question.id, comments: 'Yikes!' }, { assessment_question_id: question.id, comments: 'Bam!' }])
    expect(row).to include("Yikes!\n\nBam!")
  end

  it 'includes move profile documents count' do
    create(:document, documentable: move.profile)
    expect(row.last).to eq '1'
  end

  it 'includes 0 documents count if no profile' do
    move.person = nil
    expect(row.last).to eq '0'
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
