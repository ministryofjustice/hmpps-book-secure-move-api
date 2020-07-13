# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecord do
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_inclusion_of(:state).in_array(%w[in_progress completed confirmed]) }
  it { is_expected.to have_many(:framework_responses) }
  it { is_expected.to have_many(:framework_questions).through(:framework) }
  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:profile) }

  it 'validates uniqueness of profile' do
    person_escort_record = build(:person_escort_record)
    expect(person_escort_record).to validate_uniqueness_of(:profile)
  end

  describe '.save_with_responses!' do
    it 'returns error if profile does not exist' do
      expect { described_class.save_with_responses!(profile_id: 'some-id', version: '1.2') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns framework with version specified' do
      framework = create(:framework, version: '1.2')
      profile = create(:profile)
      described_class.save_with_responses!(profile_id: profile.id, version: '1.2')

      expect(described_class.last.framework).to eq(framework)
    end

    it 'defaults to latest framework with latest version' do
      framework = create(:framework, version: '1.2')
      create(:framework, version: '1.0')
      profile = create(:profile)
      described_class.save_with_responses!(profile_id: profile.id)

      expect(described_class.last.framework).to eq(framework)
    end

    it 'returns error if wrong version passed' do
      create(:framework, version: '1.0')
      profile = create(:profile)

      expect { described_class.save_with_responses!(profile_id: profile.id, version: '2.2') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns error if no framework found' do
      profile = create(:profile)
      expect { described_class.save_with_responses!(profile_id: profile.id) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not allow multiple person_escort_records on a profile' do
      profile = create(:profile)
      create(:framework)
      described_class.save_with_responses!(profile_id: profile.id)

      expect { described_class.save_with_responses!(profile_id: profile.id) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'sets initial state to in_progress' do
      profile = create(:profile)
      create(:framework)

      expect(described_class.save_with_responses!(profile_id: profile.id).state).to eq('in_progress')
    end

    it 'creates responses for framework questions' do
      profile = create(:profile)
      framework = create(:framework)
      create(:framework_question, :checkbox, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      person_escort_record = described_class.save_with_responses!(profile_id: profile.id)

      responses = person_escort_record.framework_responses

      expect(responses.count).to eq(2)
    end

    it 'sets correct response for framework questions' do
      profile = create(:profile)
      framework = create(:framework)
      checkbox_question = create(:framework_question, :checkbox, framework: framework)
      person_escort_record = described_class.save_with_responses!(profile_id: profile.id)

      response = person_escort_record.framework_responses.first

      expect(response).to have_attributes(
        framework_question_id: checkbox_question.id,
        type: 'FrameworkResponse::Array',
      )
    end

    it 'allows access to framework question through person escort record' do
      profile = create(:profile)
      framework = create(:framework)
      create(:framework_question, :checkbox, framework: framework)
      person_escort_record = described_class.save_with_responses!(profile_id: profile.id)

      questions = person_escort_record.framework_questions

      expect(questions.count).to eq(1)
    end
  end

  describe '#build_responses' do
    it 'persists the person_escort_record' do
      framework = create(:framework)
      create(:framework_question, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)

      expect { person_escort_record.build_responses! }.to change(described_class, :count).from(0).to(1)
    end

    it 'creates responses for a question' do
      framework = create(:framework)
      radio_question = create(:framework_question, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)
      person_escort_record.build_responses!

      expect(person_escort_record.framework_responses.first).to have_attributes(
        framework_question_id: radio_question.id,
        person_escort_record_id: person_escort_record.id,
        type: 'FrameworkResponse::String',
      )
    end

    it 'creates responses for multiple questions' do
      framework = create(:framework)
      create(:framework_question, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)

      expect { person_escort_record.build_responses! }.to change(FrameworkResponse, :count).from(0).to(2)
    end

    it 'creates responses for dependent questions' do
      framework = create(:framework)
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)

      person_escort_record = build(:person_escort_record, framework: framework, profile: create(:profile))
      person_escort_record.build_responses!
      dependent_response = FrameworkResponse.find_by(framework_question: child_question, person_escort_record: person_escort_record)

      expect(dependent_response).to have_attributes(
        framework_question_id: child_question.id,
        person_escort_record_id: person_escort_record.id,
        type: 'FrameworkResponse::Array',
      )
    end

    it 'creates responses for multiple dependent questions' do
      framework = create(:framework)
      parent_question = create(:framework_question, framework: framework)
      create(:framework_question, framework: framework, parent: parent_question)
      create(:framework_question, framework: framework, parent: parent_question)

      person_escort_record = build(:person_escort_record, framework: framework, profile: create(:profile))
      person_escort_record.build_responses!
      dependent_responses = FrameworkResponse.find_by(framework_question: parent_question, person_escort_record: person_escort_record).dependents

      expect(dependent_responses.size).to eq(2)
    end

    it 'creates responses for deeply nested dependent questions' do
      framework = create(:framework)
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)
      grand_child_question = create(:framework_question, :text, framework: framework, parent: child_question)

      person_escort_record = build(:person_escort_record, framework: framework, profile: create(:profile))
      person_escort_record.build_responses!
      dependent_response = FrameworkResponse.find_by(framework_question: grand_child_question, person_escort_record: person_escort_record)

      expect(dependent_response).to have_attributes(
        framework_question_id: grand_child_question.id,
        person_escort_record_id: person_escort_record.id,
        type: 'FrameworkResponse::String',
      )
    end

    it 'creates responses for multiple deeply nested dependent questions' do
      framework = create(:framework)
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)
      create(:framework_question, :text, framework: framework, parent: child_question)
      create(:framework_question, :text, framework: framework, parent: child_question)

      person_escort_record = build(:person_escort_record, framework: framework, profile: create(:profile))
      person_escort_record.build_responses!
      dependent_responses = FrameworkResponse.find_by(framework_question: child_question, person_escort_record: person_escort_record).dependents

      expect(dependent_responses.size).to eq(2)
    end

    it 'returns person_escort_record valildation error if record is not valid' do
      framework = create(:framework)
      create(:framework_question, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      person_escort_record = build(:person_escort_record, framework: framework, state: 'some-status', profile: create(:profile))

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
  end
end
