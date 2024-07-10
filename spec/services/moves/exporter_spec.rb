# frozen_string_literal: true

require 'rails_helper'

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
  let!(:move) { create(:move, from_location:, to_location:, person:) }
  let(:moves) { Move.where(id: move.id) }
  let!(:cancel_event) { create(:event_move_cancel, eventable: move) }

  it 'includes correct header names' do
    expect(header).to eq(described_class::STATIC_HEADINGS)
  end

  it 'has correct number of header columns' do
    expect(header.count).to eq(55)
  end

  it 'has correct number of body columns' do
    expect(row.count).to eq(55)
  end

  it 'includes move details' do
    expect(row).to include(move.status, move.reference, move.move_type, move.additional_information)
  end

  it 'includes move timestamps and date' do
    expect(row).to include(move.created_at.iso8601, move.updated_at.iso8601, move.date.strftime('%Y-%m-%d'))
  end

  it 'includes move cancelled at' do
    expect(row).to include(cancel_event.occurred_at.iso8601)
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
      question.update!(key: alert_type)
      move.profile.update!(assessment_answers: [{ assessment_question_id: question.id, comments: 'Yikes!' }])
      expect(row).to include('true', 'Yikes!')
    end
  end

  it 'includes description prefix on comments for Nomis alerts' do
    question.update!(key: 'violent')
    move.profile.update!(assessment_answers: [{ nomis_alert_description: 'Foo', assessment_question_id: question.id, comments: 'Yikes!' }])
    expect(row).to include('Foo: Yikes!')
  end

  it 'includes multiple comment lines for multiple alerts for the same question' do
    question.update!(key: 'violent')
    move.profile.update!(assessment_answers: [{ assessment_question_id: question.id, comments: 'Yikes!' }, { assessment_question_id: question.id, comments: 'Bam!' }])
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

  context 'with PER' do
    let(:framework_questions) do
      [
        create(:framework_question, section: 'risk-information'),
        create(:framework_question, section: 'risk-information'),
        create(:framework_question, section: 'health-information'),
        create(:framework_question, section: 'health-information'),
      ]
    end
    let(:flag) { build(:framework_flag, title: 'Flag 1', framework_question: framework_questions.second) }
    let(:flag2) { build(:framework_flag, title: 'Flag 2', framework_question: framework_questions.third) }
    let(:framework) { create(:framework, framework_questions:) }
    let(:person_escort_record) do
      person_escort_record = create(:person_escort_record)
      create(:string_response, framework_question: framework_questions.first, responded: true, assessmentable: person_escort_record)
      create(:string_response, framework_question: framework_questions.second, responded: true, framework_flags: [flag], assessmentable: person_escort_record)
      create(:string_response, framework_question: framework_questions.third, responded: true, framework_flags: [flag2], assessmentable: person_escort_record)

      person_escort_record
    end

    before { move.person_escort_record = person_escort_record }

    context 'when feature flag enabled' do
      around do |example|
        ClimateControl.modify(FEATURE_FLAG_CSV_ALERT_COLUMNS: 'true') do
          example.run
        end
      end

      it 'includes correct header names' do
        expect(header).to eq(described_class::STATIC_HEADINGS + ['Flag 2', 'Flag 1'])
      end

      it 'has correct number of header columns' do
        expect(header.count).to eq(57)
      end

      it 'has correct number of body columns' do
        expect(row.count).to eq(57)
      end

      it 'has the correct rows' do
        expect(row.last(2)).to eq(%w[TRUE TRUE])
      end
    end

    context 'when feature flag disabled' do
      around do |example|
        ClimateControl.modify(FEATURE_FLAG_CSV_ALERT_COLUMNS: 'false') do
          example.run
        end
      end

      it 'includes correct header names' do
        expect(header).to eq(described_class::STATIC_HEADINGS)
      end

      it 'has correct number of header columns' do
        expect(header.count).to eq(55)
      end

      it 'has correct number of body columns' do
        expect(row.count).to eq(55)
      end
    end
  end
end
