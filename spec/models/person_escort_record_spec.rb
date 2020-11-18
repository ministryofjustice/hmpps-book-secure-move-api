# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecord do
  subject { create(:person_escort_record) }

  let(:nomis_alert) do
    {
      alert_id: 2,
      alert_code: 'VI',
      alert_code_description: 'Hold separately',
      comment: 'Some comment',
      created_at: '2013-03-29',
      expires_at: '2100-06-08',
      expired: false,
      active: true,
      offender_no: 'A9127EK',
    }
  end

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_inclusion_of(:status).in_array(%w[unstarted in_progress completed confirmed]) }
  it { is_expected.to have_many(:framework_responses) }
  it { is_expected.to have_many(:framework_questions).through(:framework) }
  it { is_expected.to have_many(:framework_flags).through(:framework_responses) }
  it { is_expected.to have_many(:generic_events) }
  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:profile) }
  it { is_expected.to belong_to(:move).optional }
  it { is_expected.to belong_to(:prefill_source).optional }

  it 'validates uniqueness of profile' do
    person_escort_record = build(:person_escort_record)
    expect(person_escort_record).to validate_uniqueness_of(:profile)
  end

  it 'validates presence of confirmed_at if person_escort_record confirmed' do
    person_escort_record = build(:person_escort_record, :confirmed)
    expect(person_escort_record).to validate_presence_of(:confirmed_at)
  end

  describe '.save_with_responses!' do
    it 'returns error if move does not exist' do
      expect { described_class.save_with_responses!(move_id: 'some-id', version: '1.2') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns error if move is not associated to a profile' do
      create(:framework, version: '1.2.1')
      move = create(:move, profile: nil)

      expect { described_class.save_with_responses!(move_id: move.id, version: '1.2.1') }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'returns error if no move is passed' do
      create(:framework, version: '1.2.1')
      create(:move)

      expect { described_class.save_with_responses!(move_id: nil, version: '1.2.1') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns framework with version specified' do
      framework = create(:framework, version: '1.2.1')
      move = create(:move)
      described_class.save_with_responses!(move_id: move.id, version: '1.2.1')

      expect(described_class.last.framework).to eq(framework)
    end

    it 'returns error if wrong framework version passed' do
      create(:framework, version: '1.2.1')
      move = create(:move)

      expect { described_class.save_with_responses!(move_id: move.id, version: '1.0.1') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns error if no framework version passed' do
      create(:framework, version: '1.0.0')
      move = create(:move)
      expect { described_class.save_with_responses!(move_id: move.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns error if nil framework version passed' do
      create(:framework, version: '1.0.0')
      move = create(:move)
      expect { described_class.save_with_responses!(move_id: move.id, version: nil) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not allow multiple person_escort_records on a profile through move' do
      profile = create(:profile)
      move = create(:move, profile: profile)
      framework = create(:framework)
      described_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect { described_class.save_with_responses!(move_id: move.id, version: framework.version) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'sets initial status to unstarted' do
      move = create(:move)
      framework = create(:framework)

      expect(described_class.save_with_responses!(move_id: move.id, version: framework.version).status).to eq('unstarted')
    end

    it 'creates responses for framework questions' do
      move = create(:move)
      framework = create(:framework)
      create(:framework_question, :checkbox, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect(person_escort_record.framework_responses.count).to eq(2)
    end

    it 'creates NOMIS mappings for framework responses' do
      move = create(:move)
      framework = create(:framework)
      alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
      create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
      allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
      person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect(person_escort_record.framework_responses.first.framework_nomis_mappings.count).to eq(1)
    end

    it 'updates nomis sync status if successful' do
      move = create(:move)
      framework = create(:framework)
      alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
      create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
      allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
      person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect(person_escort_record.nomis_sync_status).to include_json(
        [
          { 'resource_type' => 'alerts', 'status' => 'success' },
        ],
      )
    end

    it 'sets correct response for framework questions' do
      move = create(:move)
      framework = create(:framework)
      checkbox_question = create(:framework_question, :checkbox, framework: framework)
      person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect(person_escort_record.framework_responses.first).to have_attributes(
        framework_question_id: checkbox_question.id,
        type: 'FrameworkResponse::Array',
      )
    end

    it 'allows access to framework question through person escort record' do
      move = create(:move)
      framework = create(:framework)
      create(:framework_question, :checkbox, framework: framework)
      person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect(person_escort_record.framework_questions.count).to eq(1)
    end

    context 'when prefilling' do
      let(:person) { create(:person) }
      let(:profile1) { create(:profile, person: person) }
      let(:profile2) { create(:profile, person: person) }
      let(:move1) { create(:move, profile: profile1) }
      let(:move2) { create(:move, profile: profile2) }
      let(:framework) { create(:framework) }

      it 'sets prefill_source on person escort record' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        prefill_source = create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])

        person_escort_record = described_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(person_escort_record.prefill_source).to eq(prefill_source)
      end

      it 'does not prefill responses if no previous confirmed person_escort_record exists for person' do
        move = create(:move)
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])
        person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

        expect(person_escort_record.framework_responses.first.value).to be_nil
      end

      it 'prefills responses from confirmed previous person escort record' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])
        person_escort_record = described_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(person_escort_record.framework_responses.first.value).to eq('No')
      end

      it 'maintains responded value as false after prefill' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])
        person_escort_record = described_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(person_escort_record.framework_responses.first).not_to be_responded
      end

      it 'sets prefilled value as true on responses' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])
        person_escort_record = described_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(person_escort_record.framework_responses.first).to be_prefilled
      end

      it 'maps values correctly to question response' do
        framework_question1 = create(:framework_question, framework: framework, prefill: true)
        framework_question2 = create(:framework_question, framework: framework, prefill: true)
        create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question1, value: 'No'), create(:string_response, framework_question: framework_question2, value: 'Yes')])
        described_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(framework_question2.reload.framework_responses.first.value).to eq('Yes')
      end

      it 'does not prefill responses with previous empty values' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: nil)])
        person_escort_record = described_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(person_escort_record.framework_responses.first.value).to be_nil
      end

      it 'does not prefill responses with no previous question' do
        framework2 = create(:framework, version: '1.1.0')
        framework_question1 = create(:framework_question, framework: framework, prefill: true)
        framework_question2 = create(:framework_question, framework: framework2, prefill: true)
        create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question1, value: 'No')])
        described_class.save_with_responses!(move_id: move2.id, version: framework2.version)

        expect(framework_question2.reload.framework_responses.first.value).to be_nil
      end

      it 'prefills responses for add_multiple_items questions' do
        dependent_framework_question = create(:framework_question, :checkbox, framework: framework, prefill: true)
        framework_question = create(:framework_question, :add_multiple_items, framework: framework, dependents: [dependent_framework_question])
        value = [{ 'item' => 1, 'responses' => [{ 'value' => ['Level 1'], 'framework_question_id' => framework_question.dependents.first.id }] }.with_indifferent_access]
        create(:person_escort_record, :confirmed, profile: profile1, move: move1, framework_responses: [create(:collection_response, :multiple_items, framework_question: framework_question, value: value)])
        person_escort_record = described_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(person_escort_record.framework_responses.first.value).to eq(value)
      end
    end
  end

  describe '#build_responses!' do
    let(:framework) { create(:framework) }

    it 'persists the person_escort_record' do
      create(:framework_question, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)

      expect { person_escort_record.build_responses! }.to change(described_class, :count).by(1)
    end

    it 'creates responses for a question' do
      radio_question = create(:framework_question, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)
      person_escort_record.build_responses!

      expect(person_escort_record.framework_responses.first).to have_attributes(
        framework_question_id: radio_question.id,
        person_escort_record_id: person_escort_record.id,
        assessmentable_id: person_escort_record.id,
        type: 'FrameworkResponse::String',
      )
    end

    it 'creates responses for multiple questions' do
      create(:framework_question, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)

      expect { person_escort_record.build_responses! }.to change(FrameworkResponse, :count).by(2)
    end

    it 'creates responses for multiple items questions' do
      create(:framework_question, :add_multiple_items, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)

      expect { person_escort_record.build_responses! }.to change(FrameworkResponse, :count).by(1)
    end

    it 'creates responses for dependent questions' do
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)

      person_escort_record = build(:person_escort_record, framework: framework, profile: create(:profile))
      person_escort_record.build_responses!
      dependent_response = FrameworkResponse.find_by(framework_question: child_question, assessmentable: person_escort_record)

      expect(dependent_response).to have_attributes(
        framework_question_id: child_question.id,
        person_escort_record_id: person_escort_record.id,
        assessmentable_id: person_escort_record.id,
        type: 'FrameworkResponse::Array',
      )
    end

    it 'creates responses for multiple dependent questions' do
      parent_question = create(:framework_question, framework: framework)
      create(:framework_question, framework: framework, parent: parent_question)
      create(:framework_question, framework: framework, parent: parent_question)

      person_escort_record = build(:person_escort_record, framework: framework, profile: create(:profile))
      person_escort_record.build_responses!
      dependent_responses = FrameworkResponse.find_by(framework_question: parent_question, assessmentable: person_escort_record).dependents

      expect(dependent_responses.count).to eq(2)
    end

    it 'creates responses for deeply nested dependent questions' do
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)
      grand_child_question = create(:framework_question, :text, framework: framework, parent: child_question)

      person_escort_record = build(:person_escort_record, framework: framework, profile: create(:profile))
      person_escort_record.build_responses!
      dependent_response = FrameworkResponse.find_by(framework_question: grand_child_question, assessmentable: person_escort_record)

      expect(dependent_response).to have_attributes(
        framework_question_id: grand_child_question.id,
        person_escort_record_id: person_escort_record.id,
        assessmentable_id: person_escort_record.id,
        type: 'FrameworkResponse::String',
      )
    end

    it 'creates responses for multiple deeply nested dependent questions' do
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)
      create(:framework_question, :text, framework: framework, parent: child_question)
      create(:framework_question, :text, framework: framework, parent: child_question)

      person_escort_record = build(:person_escort_record, framework: framework, profile: create(:profile))
      person_escort_record.build_responses!
      dependent_responses = FrameworkResponse.find_by(framework_question: child_question, assessmentable: person_escort_record).dependents

      expect(dependent_responses.count).to eq(2)
    end

    it 'returns person_escort_record validation error if record is not valid' do
      create(:framework_question, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      person_escort_record = build(:person_escort_record, framework: framework, status: 'some-status', profile: create(:profile))

      expect { person_escort_record.build_responses! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not persist any responses if there are any invalid person_escort_record records' do
      framework = create(:framework)
      framework_responses = [
        build(:framework_response, type: 'wrong-type'),
      ]
      person_escort_record = build(
        :person_escort_record,
        framework: framework,
        profile: create(:profile),
        framework_responses: framework_responses,
      )

      person_escort_record.build_responses!
    rescue ActiveRecord::RecordInvalid
      expect(FrameworkResponse.count).to be_zero
    end

    it 'raises an error if transaction fails twice' do
      create(:framework_question, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)
      allow(person_escort_record).to receive(:save!).and_raise(ActiveRecord::PreparedStatementCacheExpired).twice

      expect { person_escort_record.build_responses! }.to raise_error(ActiveRecord::PreparedStatementCacheExpired)
    end

    it 'retries the transaction if it fails only once and saves person_escort_record' do
      radio_question = create(:framework_question, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)

      # Allow update to fail first time, and second time to complete transaction
      return_values = [:raise, true]
      allow(person_escort_record).to receive(:save!).twice do
        return_value = return_values.shift
        return_value == :raise ? raise(ActiveRecord::PreparedStatementCacheExpired) : person_escort_record.save
      end

      person_escort_record.build_responses!

      expect(person_escort_record.framework_responses.first).to have_attributes(
        framework_question_id: radio_question.id,
        person_escort_record_id: person_escort_record.id,
        assessmentable_id: person_escort_record.id,
        type: 'FrameworkResponse::String',
      )
    end
  end

  describe '#import_nomis_mappings!' do
    before do
      allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
    end

    it 'does nothing if no move associated to person escort record' do
      framework = create(:framework)
      profile = create(:profile)
      alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
      question = create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
      response = create(:string_response, framework_question: question)
      person_escort_record = create(:person_escort_record, framework: framework, profile: profile, framework_responses: [response])

      expect { person_escort_record.import_nomis_mappings! }.not_to change(FrameworkNomisMapping, :count)
    end

    it 'does nothing if move is not from a prison' do
      framework = create(:framework)
      move = create(:move, :video_remand)
      alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
      question = create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
      response = create(:string_response, framework_question: question)
      person_escort_record = create(:person_escort_record, framework: framework, move: move, framework_responses: [response])

      expect { person_escort_record.import_nomis_mappings! }.not_to change(FrameworkNomisMapping, :count)
    end

    it 'imports nomis mappings if move is a prison' do
      framework = create(:framework)
      move = create(:move)
      alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
      question = create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
      response = create(:string_response, framework_question: question)
      person_escort_record = create(:person_escort_record, framework: framework, move: move, framework_responses: [response])

      expect { person_escort_record.import_nomis_mappings! }.to change(FrameworkNomisMapping, :count).by(1)
    end
  end

  describe '#section_progress' do
    it 'returns an empty hash if no responses present' do
      person_escort_record = create(:person_escort_record)

      expect(person_escort_record.section_progress).to be_empty
    end

    it 'returns all section values for framework questions' do
      person_escort_record = create(:person_escort_record, :with_responses)
      question_sections = person_escort_record.framework_questions.pluck(:section).uniq
      progress_sections = person_escort_record.section_progress.map { |section| section[:key] }

      expect(progress_sections).to match_array(question_sections)
    end

    it 'returns a section as `not_started` if all responded values are false' do
      person_escort_record = create(:person_escort_record)
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: false)
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: false)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'not_started',
        },
      )
    end

    it 'returns a section as `in_progress` if some responded values are true' do
      person_escort_record = create(:person_escort_record)
      create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: false)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'in_progress',
        },
      )
    end

    it 'returns a section as `in_progress` if not all required dependent responses responded' do
      person_escort_record = create(:person_escort_record)
      # Non dependent Responses
      create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      parent_response = create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      # Dependent responses on parent_response
      child_response = create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true, parent: parent_response, dependent_value: 'Yes', parent_question: parent_response.framework_question)
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: false, parent: parent_response, dependent_value: 'No', parent_question: parent_response.framework_question)
      # Dependent responses on child_response
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'Yes', parent_question: child_response.framework_question)
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'No', parent_question: child_response.framework_question)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'in_progress',
        },
      )
    end

    it 'returns a section as `completed` if all responded values are true' do
      person_escort_record = create(:person_escort_record)
      create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: true)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'completed',
        },
      )
    end

    it 'returns a section as `completed` if all required dependent responses responded' do
      person_escort_record = create(:person_escort_record)

      # Non dependent Responses
      create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      parent_response = create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      # Dependent responses on parent_response
      child_response = create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true, parent: parent_response, dependent_value: 'Yes', parent_question: parent_response.framework_question)
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: false, parent: parent_response, dependent_value: 'No', parent_question: parent_response.framework_question)
      # Dependent responses on child_response
      create_response(assessmentable: person_escort_record, section: 'risk', value: 'Yes', responded: true, parent: child_response, dependent_value: 'Yes', parent_question: child_response.framework_question)
      create_response(assessmentable: person_escort_record, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'No', parent_question: child_response.framework_question)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'completed',
        },
      )
    end

    it 'returns a section as `not_started` if all responded values are false even if prefilled' do
      person_escort_record = create(:person_escort_record, :prefilled)
      create_response(assessmentable: person_escort_record, section: 'risk', value: 'No', responded: false, prefilled: true)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'not_started',
        },
      )
    end
  end

  describe '#update_status!' do
    it 'sets initial status to `unstarted`' do
      person_escort_record = create(:person_escort_record)
      create(:string_response, value: nil, assessmentable: person_escort_record)
      create(:string_response, value: nil, assessmentable: person_escort_record)
      person_escort_record.update_status!

      expect(person_escort_record).to be_unstarted
    end

    it 'sets status to `in_progress` if at least one response provided' do
      person_escort_record = create(:person_escort_record)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      create(:string_response, value: nil, responded: false, assessmentable: person_escort_record)
      person_escort_record.update_status!

      expect(person_escort_record).to be_in_progress
    end

    it 'sets status to `completed` if all responses provided from `unstarted`' do
      person_escort_record = create(:person_escort_record)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      person_escort_record.update_status!

      expect(person_escort_record).to be_completed
    end

    it 'sets status to `completed` if all responses provided from `in_progress`' do
      person_escort_record = create(:person_escort_record, :in_progress)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      person_escort_record.update_status!

      expect(person_escort_record).to be_completed
    end

    it 'sets status to `completed` from itself if response changed' do
      person_escort_record = create(:person_escort_record, :completed)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      person_escort_record.update_status!

      expect(person_escort_record).to be_completed
    end

    it 'sets `completed_at` timestamp when status transitions to `completed`' do
      completed_at_timestamp = Time.zone.now
      allow(Time).to receive(:now).and_return(completed_at_timestamp)
      person_escort_record = create(:person_escort_record, :in_progress)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      person_escort_record.update_status!

      expect(person_escort_record.completed_at).to eq(completed_at_timestamp)
    end

    it 'sets status back to `in_progress` from `completed` if response cleared' do
      person_escort_record = create(:person_escort_record, :completed)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      create(:string_response, value: nil, responded: false, assessmentable: person_escort_record)
      person_escort_record.update_status!

      expect(person_escort_record).to be_in_progress
    end

    it 'sets `completed_at` timestamp only on first occurence' do
      old_completed_at_timestamp = Time.zone.now - 1.day
      new_completed_at_timestamp = Time.zone.now
      allow(Time).to receive(:now).and_return(new_completed_at_timestamp)
      person_escort_record = create(:person_escort_record, :completed, completed_at: old_completed_at_timestamp)
      create(:string_response, responded: true, assessmentable: person_escort_record)
      response = create(:string_response, value: nil, responded: false, assessmentable: person_escort_record)
      person_escort_record.update_status!
      response.update(value: 'Yes')
      person_escort_record.update_status!

      expect(person_escort_record.completed_at).to eq(old_completed_at_timestamp)
    end

    it 'sets status to `in_progress` from itself if response changed' do
      person_escort_record = create(:person_escort_record, :in_progress)
      create(:string_response, value: 'No', responded: true, assessmentable: person_escort_record)
      create(:string_response, value: nil, responded: false, assessmentable: person_escort_record)
      person_escort_record.update_status!

      expect(person_escort_record).to be_in_progress
    end

    it 'raises error if status is `confirmed`' do
      person_escort_record = create(:person_escort_record, :confirmed)
      expect { person_escort_record.update_status! }.to raise_error(FiniteMachine::InvalidStateError)
    end
  end

  describe '#confirm!' do
    it 'sets status to `confirmed` if current status is `completed`' do
      person_escort_record = create(:person_escort_record, :completed)
      person_escort_record.confirm!('confirmed')

      expect(person_escort_record).to be_confirmed
    end

    it 'sets `confirmed` timestamp to `confirmed_at`' do
      confirmed_at_timestamp = Time.zone.now
      person_escort_record = create(:person_escort_record, :completed)
      allow(Time).to receive(:now).and_return(confirmed_at_timestamp)
      person_escort_record.confirm!('confirmed')

      expect(person_escort_record.confirmed_at).to eq(confirmed_at_timestamp)
    end

    it 'does not update status if status is wrong value' do
      person_escort_record = create(:person_escort_record, :completed)
      person_escort_record.confirm!('completed')

      expect(person_escort_record).to be_completed
    end

    it 'does not update status if previous status not valid' do
      person_escort_record = create(:person_escort_record, :in_progress)

      expect { person_escort_record.confirm!('confirmed') }.to raise_error(ActiveModel::ValidationError)
      expect(person_escort_record.errors.messages[:status]).to contain_exactly("can't update to 'confirmed' from 'in_progress'")
    end

    it 'does not update status if current status the same' do
      person_escort_record = create(:person_escort_record, :confirmed)

      expect { person_escort_record.confirm!('confirmed') }.to raise_error(ActiveModel::ValidationError)
      expect(person_escort_record.errors.messages[:status]).to contain_exactly("can't update to 'confirmed' from 'confirmed'")
    end
  end

  describe '#handle_event_run' do
    subject(:person_escort_record) { create(:person_escort_record) }

    context 'when the person_escort_record has changed but is not valid' do
      before do
        person_escort_record.status = 'foo'
      end

      it 'does not save the person_escort_record' do
        person_escort_record.handle_event_run

        expect(person_escort_record.reload.status).not_to eq('foo')
      end
    end

    context 'when the person_escort_record has changed and is valid' do
      before do
        person_escort_record.status = 'in_progress'
      end

      it 'saves the person_escort_record' do
        person_escort_record.handle_event_run

        expect(person_escort_record.reload.status).to eq('in_progress')
      end
    end
  end

  def create_response(options = {})
    question = create(:framework_question, framework: options[:assessmentable].framework, section: options[:section], dependent_value: options[:dependent_value], parent: options[:parent_question])
    create(:string_response, value: options[:value], framework_question: question, assessmentable: options[:assessmentable], responded: options[:responded], parent: options[:parent])
  end
end
