# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecord do
  subject { create(:person_escort_record) }

  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_inclusion_of(:state).in_array(%w[unstarted in_progress completed confirmed printed]) }
  it { is_expected.to have_many(:framework_responses) }
  it { is_expected.to have_many(:framework_questions).through(:framework) }
  it { is_expected.to have_many(:flags).through(:framework_responses) }
  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:profile) }

  it 'validates uniqueness of profile' do
    person_escort_record = build(:person_escort_record)
    expect(person_escort_record).to validate_uniqueness_of(:profile)
  end

  it 'validates presence of confirmed_at if person_escort_record confirmed' do
    person_escort_record = build(:person_escort_record, :confirmed)
    expect(person_escort_record).to validate_presence_of(:confirmed_at)
  end

  it 'validates presence of printed_at if person_escort_record printed' do
    person_escort_record = build(:person_escort_record, :printed)
    expect(person_escort_record).to validate_presence_of(:printed_at)
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

      expect(person_escort_record.framework_responses.count).to eq(2)
    end

    it 'sets correct response for framework questions' do
      profile = create(:profile)
      framework = create(:framework)
      checkbox_question = create(:framework_question, :checkbox, framework: framework)
      person_escort_record = described_class.save_with_responses!(profile_id: profile.id)

      expect(person_escort_record.framework_responses.first).to have_attributes(
        framework_question_id: checkbox_question.id,
        type: 'FrameworkResponse::Array',
      )
    end

    it 'allows access to framework question through person escort record' do
      profile = create(:profile)
      framework = create(:framework)
      create(:framework_question, :checkbox, framework: framework)
      person_escort_record = described_class.save_with_responses!(profile_id: profile.id)

      expect(person_escort_record.framework_questions.count).to eq(1)
    end
  end

  describe '#build_responses' do
    it 'persists the person_escort_record' do
      framework = create(:framework)
      create(:framework_question, framework: framework)
      profile = create(:profile)
      person_escort_record = build(:person_escort_record, framework: framework, profile: profile)

      expect { person_escort_record.build_responses! }.to change(described_class, :count).by(1)
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

      expect { person_escort_record.build_responses! }.to change(FrameworkResponse, :count).by(2)
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

      expect(dependent_responses.count).to eq(2)
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

      expect(dependent_responses.count).to eq(2)
    end

    it 'returns person_escort_record validation error if record is not valid' do
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
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: false)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: false)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'not_started',
        },
      )
    end

    it 'returns a section as `in_progress` if some responded values are true' do
      person_escort_record = create(:person_escort_record)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: false)

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
      create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      parent_response = create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      # Dependent responses on parent_response
      child_response = create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true, parent: parent_response, dependent_value: 'Yes', parent_question: parent_response.framework_question)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: false, parent: parent_response, dependent_value: 'No', parent_question: parent_response.framework_question)
      # Dependent responses on child_response
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'Yes', parent_question: child_response.framework_question)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'No', parent_question: child_response.framework_question)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'in_progress',
        },
      )
    end

    it 'returns a section as `completed` if all responded values are true' do
      person_escort_record = create(:person_escort_record)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: true)

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
      create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      parent_response = create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true)
      # Dependent responses on parent_response
      child_response = create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true, parent: parent_response, dependent_value: 'Yes', parent_question: parent_response.framework_question)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: false, parent: parent_response, dependent_value: 'No', parent_question: parent_response.framework_question)
      # Dependent responses on child_response
      create_response(person_escort_record: person_escort_record, section: 'risk', value: 'Yes', responded: true, parent: child_response, dependent_value: 'Yes', parent_question: child_response.framework_question)
      create_response(person_escort_record: person_escort_record, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'No', parent_question: child_response.framework_question)

      expect(person_escort_record.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'completed',
        },
      )
    end
  end

  describe '#update_state!' do
    it 'sets initial state to `unstarted`' do
      person_escort_record = create(:person_escort_record)
      create(:string_response, value: nil, person_escort_record: person_escort_record)
      create(:string_response, value: nil, person_escort_record: person_escort_record)
      person_escort_record.update_state!

      expect(person_escort_record).to be_unstarted
    end

    it 'sets state to `in_progress` if at least one response provided' do
      person_escort_record = create(:person_escort_record)
      create(:string_response, responded: true, person_escort_record: person_escort_record)
      create(:string_response, value: nil, responded: false, person_escort_record: person_escort_record)
      person_escort_record.update_state!

      expect(person_escort_record).to be_in_progress
    end

    it 'sets state to `completed` if all responses provided from `unstarted`' do
      person_escort_record = create(:person_escort_record)
      create(:string_response, responded: true, person_escort_record: person_escort_record)
      create(:string_response, responded: true, person_escort_record: person_escort_record)
      person_escort_record.update_state!

      expect(person_escort_record).to be_completed
    end

    it 'sets state to `completed` if all responses provided from `in_progress`' do
      person_escort_record = create(:person_escort_record, :in_progress)
      create(:string_response, responded: true, person_escort_record: person_escort_record)
      create(:string_response, responded: true, person_escort_record: person_escort_record)
      person_escort_record.update_state!

      expect(person_escort_record).to be_completed
    end

    it 'sets state back to `in_progress` from `completed` if response cleared' do
      person_escort_record = create(:person_escort_record, :completed)
      create(:string_response, responded: true, person_escort_record: person_escort_record)
      create(:string_response, value: nil, responded: false, person_escort_record: person_escort_record)
      person_escort_record.update_state!

      expect(person_escort_record).to be_in_progress
    end

    it 'raises error if state is `confirmed`' do
      person_escort_record = create(:person_escort_record, :confirmed)
      expect { person_escort_record.update_state! }.to raise_error(FiniteMachine::InvalidStateError)
    end

    it 'raises error if state is `printed`' do
      person_escort_record = create(:person_escort_record, :printed)
      expect { person_escort_record.update_state! }.to raise_error(FiniteMachine::InvalidStateError)
    end
  end

  def create_response(options = {})
    question = create(:framework_question, framework: options[:person_escort_record].framework, section: options[:section], dependent_value: options[:dependent_value], parent: options[:parent_question])
    create(:string_response, value: options[:value], framework_question: question, person_escort_record: options[:person_escort_record], responded: options[:responded], parent: options[:parent])
  end
end
