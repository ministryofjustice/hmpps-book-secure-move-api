RSpec.shared_examples 'a framework assessment' do |assessment_type, assessment_class|
  subject { create(assessment_type) }

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
  it { is_expected.to belong_to(:prefill_source).optional }

  it 'validates uniqueness of profile' do
    assessment = build(assessment_type)
    expect(assessment).to validate_uniqueness_of(:profile)
  end

  it 'validates presence of confirmed_at if assessment confirmed' do
    assessment = build(assessment_type, :confirmed)
    expect(assessment).to validate_presence_of(:confirmed_at)
  end

  describe '.save_with_responses!' do
    it 'returns error if move does not exist' do
      expect { assessment_class.save_with_responses!(move_id: 'some-id', version: '1.2') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns error if move is not associated to a profile' do
      create(:framework, name: assessment_type.to_s.dasherize, version: '1.2.1')
      move = create(:move, from_location: from_location, profile: nil)

      expect { assessment_class.save_with_responses!(move_id: move.id, version: '1.2.1') }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'returns error if no move is passed' do
      create(:framework, name: assessment_type.to_s.dasherize, version: '1.2.1')
      create(:move, from_location: from_location)

      expect { assessment_class.save_with_responses!(move_id: nil, version: '1.2.1') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns framework with version specified' do
      framework = create(:framework, name: assessment_type.to_s.dasherize, version: '1.2.1')
      move = create(:move, from_location: from_location)
      assessment_class.save_with_responses!(move_id: move.id, version: '1.2.1')

      expect(assessment_class.last.framework).to eq(framework)
    end

    it 'returns error if wrong framework version passed' do
      create(:framework, name: assessment_type.to_s.dasherize, version: '1.2.1')
      move = create(:move, from_location: from_location)

      expect { assessment_class.save_with_responses!(move_id: move.id, version: '1.0.1') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns error if no framework version passed' do
      create(:framework, name: assessment_type.to_s.dasherize, version: '1.0.0')
      move = create(:move, from_location: from_location)
      expect { assessment_class.save_with_responses!(move_id: move.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns error if nil framework version passed' do
      create(:framework, name: assessment_type.to_s.dasherize, version: '1.0.0')
      move = create(:move, from_location: from_location)
      expect { assessment_class.save_with_responses!(move_id: move.id, version: nil) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not allow multiple assessments on a profile through move' do
      profile = create(:profile)
      move = create(:move, from_location: from_location, profile: profile)
      framework = create(:framework, name: assessment_type.to_s.dasherize)
      assessment_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect { assessment_class.save_with_responses!(move_id: move.id, version: framework.version) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'sets initial status to unstarted' do
      move = create(:move, from_location: from_location)
      framework = create(:framework, name: assessment_type.to_s.dasherize)

      expect(assessment_class.save_with_responses!(move_id: move.id, version: framework.version).status).to eq('unstarted')
    end

    it 'creates responses for framework questions' do
      move = create(:move, from_location: from_location)
      framework = create(:framework, name: assessment_type.to_s.dasherize)
      create(:framework_question, :checkbox, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      assessment = assessment_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect(assessment.framework_responses.count).to eq(2)
    end

    it 'sets correct response for framework questions' do
      move = create(:move, from_location: from_location)
      framework = create(:framework, name: assessment_type.to_s.dasherize)
      checkbox_question = create(:framework_question, :checkbox, framework: framework)
      assessment = assessment_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect(assessment.framework_responses.first).to have_attributes(
        framework_question_id: checkbox_question.id,
        type: 'FrameworkResponse::Array',
      )
    end

    it 'allows access to framework question through assessment' do
      move = create(:move, from_location: from_location)
      framework = create(:framework, name: assessment_type.to_s.dasherize)
      create(:framework_question, :checkbox, framework: framework)
      assessment = assessment_class.save_with_responses!(move_id: move.id, version: framework.version)

      expect(assessment.framework_questions.count).to eq(1)
    end

    context 'when prefilling' do
      let(:person) { create(:person) }
      let(:profile1) { create(:profile, person: person) }
      let(:profile2) { create(:profile, person: person) }
      let(:move1) { create(:move, from_location: from_location, profile: profile1) }
      let(:move2) { create(:move, from_location: from_location, profile: profile2) }
      let(:framework) { create(:framework, name: assessment_type.to_s.dasherize) }

      it 'sets prefill_source on assessment' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        prefill_source = create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])

        assessment = assessment_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(assessment.prefill_source).to eq(prefill_source)
      end

      it 'does not prefill responses if no previous confirmed assessment exists for person' do
        move = create(:move, from_location: from_location)
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])
        assessment = assessment_class.save_with_responses!(move_id: move.id, version: framework.version)

        expect(assessment.framework_responses.first.value).to be_nil
      end

      it 'prefills responses from confirmed previous assessment' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])
        assessment = assessment_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(assessment.framework_responses.first.value).to eq('No')
      end

      it 'maintains responded value as false after prefill' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])
        assessment = assessment_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(assessment.framework_responses.first).not_to be_responded
      end

      it 'sets prefilled value as true on responses' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: 'No')])
        assessment = assessment_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(assessment.framework_responses.first).to be_prefilled
      end

      it 'maps values correctly to question response' do
        framework_question1 = create(:framework_question, framework: framework, prefill: true)
        framework_question2 = create(:framework_question, framework: framework, prefill: true)
        create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question1, value: 'No'), create(:string_response, framework_question: framework_question2, value: 'Yes')])
        assessment_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(framework_question2.reload.framework_responses.first.value).to eq('Yes')
      end

      it 'does not prefill responses with previous empty values' do
        framework_question = create(:framework_question, framework: framework, prefill: true)
        create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question, value: nil)])
        assessment = assessment_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(assessment.framework_responses.first.value).to be_nil
      end

      it 'does not prefill responses with no previous question' do
        framework2 = create(:framework, name: assessment_type.to_s.dasherize, version: '1.1.0')
        framework_question1 = create(:framework_question, framework: framework, prefill: true)
        framework_question2 = create(:framework_question, framework: framework2, prefill: true)
        create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:string_response, framework_question: framework_question1, value: 'No')])
        assessment_class.save_with_responses!(move_id: move2.id, version: framework2.version)

        expect(framework_question2.reload.framework_responses.first.value).to be_nil
      end

      it 'prefills responses for add_multiple_items questions' do
        dependent_framework_question = create(:framework_question, :checkbox, framework: framework, prefill: true)
        framework_question = create(:framework_question, :add_multiple_items, framework: framework, dependents: [dependent_framework_question])
        value = [{ 'item' => 1, 'responses' => [{ 'value' => ['Level 1'], 'framework_question_id' => framework_question.dependents.first.id }] }.with_indifferent_access]
        create(assessment_type, :confirmed, profile: profile1, move: move1, framework_responses: [create(:collection_response, :multiple_items, framework_question: framework_question, value: value)])
        assessment = assessment_class.save_with_responses!(move_id: move2.id, version: framework.version)

        expect(assessment.framework_responses.first.value).to eq(value)
      end
    end
  end

  describe '#build_responses!' do
    let(:framework) { create(:framework, name: assessment_type.to_s.dasherize) }

    it 'persists the assessment' do
      create(:framework_question, framework: framework)
      profile = create(:profile)
      assessment = build(assessment_type, framework: framework, profile: profile)

      expect { assessment.build_responses! }.to change(assessment_class, :count).by(1)
    end

    it 'creates responses for a question' do
      radio_question = create(:framework_question, framework: framework)
      profile = create(:profile)
      assessment = build(assessment_type, framework: framework, profile: profile)
      assessment.build_responses!

      expect(assessment.framework_responses.first).to have_attributes(
        framework_question_id: radio_question.id,
        assessmentable_id: assessment.id,
        type: 'FrameworkResponse::String',
      )
    end

    it 'creates responses for multiple questions' do
      create(:framework_question, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      profile = create(:profile)
      assessment = build(assessment_type, framework: framework, profile: profile)

      expect { assessment.build_responses! }.to change(FrameworkResponse, :count).by(2)
    end

    it 'creates responses for multiple items questions' do
      create(:framework_question, :add_multiple_items, framework: framework)
      profile = create(:profile)
      assessment = build(assessment_type, framework: framework, profile: profile)

      expect { assessment.build_responses! }.to change(FrameworkResponse, :count).by(1)
    end

    it 'creates responses for dependent questions' do
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)

      assessment = build(assessment_type, framework: framework, profile: create(:profile))
      assessment.build_responses!
      dependent_response = FrameworkResponse.find_by(framework_question: child_question, assessmentable: assessment)

      expect(dependent_response).to have_attributes(
        framework_question_id: child_question.id,
        assessmentable_id: assessment.id,
        type: 'FrameworkResponse::Array',
      )
    end

    it 'creates responses for multiple dependent questions' do
      parent_question = create(:framework_question, framework: framework)
      create(:framework_question, framework: framework, parent: parent_question)
      create(:framework_question, framework: framework, parent: parent_question)

      assessment = build(assessment_type, framework: framework, profile: create(:profile))
      assessment.build_responses!
      dependent_responses = FrameworkResponse.find_by(framework_question: parent_question, assessmentable: assessment).dependents

      expect(dependent_responses.count).to eq(2)
    end

    it 'creates responses for deeply nested dependent questions' do
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)
      grand_child_question = create(:framework_question, :text, framework: framework, parent: child_question)

      assessment = build(assessment_type, framework: framework, profile: create(:profile))
      assessment.build_responses!
      dependent_response = FrameworkResponse.find_by(framework_question: grand_child_question, assessmentable: assessment)

      expect(dependent_response).to have_attributes(
        framework_question_id: grand_child_question.id,
        assessmentable_id: assessment.id,
        type: 'FrameworkResponse::String',
      )
    end

    it 'creates responses for multiple deeply nested dependent questions' do
      parent_question = create(:framework_question, framework: framework)
      child_question = create(:framework_question, :checkbox, framework: framework, parent: parent_question)
      create(:framework_question, :text, framework: framework, parent: child_question)
      create(:framework_question, :text, framework: framework, parent: child_question)

      assessment = build(assessment_type, framework: framework, profile: create(:profile))
      assessment.build_responses!
      dependent_responses = FrameworkResponse.find_by(framework_question: child_question, assessmentable: assessment).dependents

      expect(dependent_responses.count).to eq(2)
    end

    it 'returns assessment validation error if record is not valid' do
      create(:framework_question, framework: framework)
      create(:framework_question, :checkbox, framework: framework)
      assessment = build(assessment_type, framework: framework, status: 'some-status', profile: create(:profile))

      expect { assessment.build_responses! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not persist any responses if there are any invalid assessment records' do
      framework = create(:framework, name: assessment_type.to_s.dasherize)
      framework_responses = [
        build(:framework_response, type: 'wrong-type'),
      ]
      assessment = build(
        assessment_type,
        framework: framework,
        profile: create(:profile),
        framework_responses: framework_responses,
      )

      assessment.build_responses!
    rescue ActiveRecord::RecordInvalid
      expect(FrameworkResponse.count).to be_zero
    end

    it 'raises an error if transaction fails twice' do
      create(:framework_question, framework: framework)
      profile = create(:profile)
      assessment = build(assessment_type, framework: framework, profile: profile)
      allow(assessment).to receive(:save!).and_raise(ActiveRecord::PreparedStatementCacheExpired).twice

      expect { assessment.build_responses! }.to raise_error(ActiveRecord::PreparedStatementCacheExpired)
    end

    it 'retries the transaction if it fails only once and saves assessment' do
      radio_question = create(:framework_question, framework: framework)
      profile = create(:profile)
      assessment = build(assessment_type, framework: framework, profile: profile)

      # Allow update to fail first time, and second time to complete transaction
      return_values = [:raise, true]
      allow(assessment).to receive(:save!).twice do
        return_value = return_values.shift
        return_value == :raise ? raise(ActiveRecord::PreparedStatementCacheExpired) : assessment.save
      end

      assessment.build_responses!

      expect(assessment.framework_responses.first).to have_attributes(
        framework_question_id: radio_question.id,
        assessmentable_id: assessment.id,
        type: 'FrameworkResponse::String',
      )
    end
  end

  describe '#import_nomis_mappings!' do
    before do
      allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
    end

    it 'does nothing if move is not from a prison' do
      framework = create(:framework, name: assessment_type.to_s.dasherize)
      move = create(:move, :from_stc_to_court)
      alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
      question = create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
      response = create(:string_response, framework_question: question)
      assessment = create(assessment_type, framework: framework, move: move, framework_responses: [response])

      expect { assessment.import_nomis_mappings! }.not_to change(FrameworkNomisMapping, :count)
    end
  end

  describe '#section_progress' do
    it 'returns an empty hash if no responses present' do
      assessment = create(assessment_type)

      expect(assessment.section_progress).to be_empty
    end

    it 'returns all section values for framework questions' do
      assessment = create(assessment_type, :with_responses)
      question_sections = assessment.framework_questions.pluck(:section).uniq
      progress_sections = assessment.section_progress.map { |section| section[:key] }

      expect(progress_sections).to match_array(question_sections)
    end

    it 'returns a section as `not_started` if all responded values are false' do
      assessment = create(assessment_type)
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: false)
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: false)

      expect(assessment.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'not_started',
        },
      )
    end

    it 'returns a section as `in_progress` if some responded values are true' do
      assessment = create(assessment_type)
      create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true)
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: false)

      expect(assessment.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'in_progress',
        },
      )
    end

    it 'returns a section as `in_progress` if not all required dependent responses responded' do
      assessment = create(assessment_type)
      # Non dependent Responses
      create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true)
      parent_response = create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true)
      # Dependent responses on parent_response
      child_response = create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true, parent: parent_response, dependent_value: 'Yes', parent_question: parent_response.framework_question)
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: false, parent: parent_response, dependent_value: 'No', parent_question: parent_response.framework_question)
      # Dependent responses on child_response
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'Yes', parent_question: child_response.framework_question)
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'No', parent_question: child_response.framework_question)

      expect(assessment.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'in_progress',
        },
      )
    end

    it 'returns a section as `completed` if all responded values are true' do
      assessment = create(assessment_type)
      create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true)
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: true)

      expect(assessment.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'completed',
        },
      )
    end

    it 'returns a section as `completed` if all required dependent responses responded' do
      assessment = create(assessment_type)

      # Non dependent Responses
      create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true)
      parent_response = create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true)
      # Dependent responses on parent_response
      child_response = create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true, parent: parent_response, dependent_value: 'Yes', parent_question: parent_response.framework_question)
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: false, parent: parent_response, dependent_value: 'No', parent_question: parent_response.framework_question)
      # Dependent responses on child_response
      create_response(assessmentable: assessment, section: 'risk', value: 'Yes', responded: true, parent: child_response, dependent_value: 'Yes', parent_question: child_response.framework_question)
      create_response(assessmentable: assessment, section: 'risk', value: nil, responded: false, parent: child_response, dependent_value: 'No', parent_question: child_response.framework_question)

      expect(assessment.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'completed',
        },
      )
    end

    it 'returns a section as `not_started` if all responded values are false even if prefilled' do
      assessment = create(assessment_type, :prefilled)
      create_response(assessmentable: assessment, section: 'risk', value: 'No', responded: false, prefilled: true)

      expect(assessment.section_progress).to contain_exactly(
        {
          key: 'risk',
          status: 'not_started',
        },
      )
    end
  end

  describe '#update_status!' do
    it 'sets initial status to `unstarted`' do
      assessment = create(assessment_type)
      create(:string_response, value: nil, assessmentable: assessment)
      create(:string_response, value: nil, assessmentable: assessment)
      assessment.update_status!

      expect(assessment).to be_unstarted
    end

    it 'sets status to `in_progress` if at least one response provided' do
      assessment = create(assessment_type)
      create(:string_response, responded: true, assessmentable: assessment)
      create(:string_response, value: nil, responded: false, assessmentable: assessment)
      assessment.update_status!

      expect(assessment).to be_in_progress
    end

    it 'sets status to `completed` if all responses provided from `unstarted`' do
      assessment = create(assessment_type)
      create(:string_response, responded: true, assessmentable: assessment)
      create(:string_response, responded: true, assessmentable: assessment)
      assessment.update_status!

      expect(assessment).to be_completed
    end

    it 'sets status to `completed` if all responses provided from `in_progress`' do
      assessment = create(assessment_type, :in_progress)
      create(:string_response, responded: true, assessmentable: assessment)
      create(:string_response, responded: true, assessmentable: assessment)
      assessment.update_status!

      expect(assessment).to be_completed
    end

    it 'sets status to `completed` from itself if response changed' do
      assessment = create(assessment_type, :completed)
      create(:string_response, responded: true, assessmentable: assessment)
      create(:string_response, responded: true, assessmentable: assessment)
      assessment.update_status!

      expect(assessment).to be_completed
    end

    it 'sets `completed_at` timestamp when status transitions to `completed`' do
      completed_at_timestamp = Time.zone.now
      allow(Time).to receive(:now).and_return(completed_at_timestamp)
      assessment = create(assessment_type, :in_progress)
      create(:string_response, responded: true, assessmentable: assessment)
      assessment.update_status!

      expect(assessment.completed_at).to eq(completed_at_timestamp)
    end

    it 'sets status back to `in_progress` from `completed` if response cleared' do
      assessment = create(assessment_type, :completed)
      create(:string_response, responded: true, assessmentable: assessment)
      create(:string_response, value: nil, responded: false, assessmentable: assessment)
      assessment.update_status!

      expect(assessment).to be_in_progress
    end

    it 'sets `completed_at` timestamp only on first occurence' do
      old_completed_at_timestamp = Time.zone.now - 1.day
      new_completed_at_timestamp = Time.zone.now
      allow(Time).to receive(:now).and_return(new_completed_at_timestamp)
      assessment = create(assessment_type, :completed, completed_at: old_completed_at_timestamp)
      create(:string_response, responded: true, assessmentable: assessment)
      response = create(:string_response, value: nil, responded: false, assessmentable: assessment)
      assessment.update_status!
      response.update(value: 'Yes')
      assessment.update_status!

      expect(assessment.completed_at).to eq(old_completed_at_timestamp)
    end

    it 'sets status to `in_progress` from itself if response changed' do
      assessment = create(assessment_type, :in_progress)
      create(:string_response, value: 'No', responded: true, assessmentable: assessment)
      create(:string_response, value: nil, responded: false, assessmentable: assessment)
      assessment.update_status!

      expect(assessment).to be_in_progress
    end

    it 'raises error if status is `confirmed`' do
      assessment = create(assessment_type, :confirmed)
      expect { assessment.update_status! }.to raise_error(FiniteMachine::InvalidStateError)
    end
  end

  describe '#confirm!' do
    it 'sets status to `confirmed` if current status is `completed`' do
      assessment = create(assessment_type, :completed)
      assessment.confirm!('confirmed')

      expect(assessment).to be_confirmed
    end

    it 'sets `confirmed` timestamp to `confirmed_at`' do
      confirmed_at_timestamp = Time.zone.now
      assessment = create(assessment_type, :completed)
      allow(Time).to receive(:now).and_return(confirmed_at_timestamp)
      assessment.confirm!('confirmed')

      expect(assessment.confirmed_at).to eq(confirmed_at_timestamp)
    end

    it 'does not update status if status is wrong value' do
      assessment = create(assessment_type, :completed)
      assessment.confirm!('completed')

      expect(assessment).to be_completed
    end

    it 'does not update status if previous status not valid' do
      assessment = create(assessment_type, :in_progress)

      expect { assessment.confirm!('confirmed') }.to raise_error(ActiveModel::ValidationError)
      expect(assessment.errors.messages[:status]).to contain_exactly("can't update to 'confirmed' from 'in_progress'")
    end

    it 'does not update status if current status the same' do
      assessment = create(assessment_type, :confirmed)

      expect { assessment.confirm!('confirmed') }.to raise_error(ActiveModel::ValidationError)
      expect(assessment.errors.messages[:status]).to contain_exactly("can't update to 'confirmed' from 'confirmed'")
    end
  end

  describe '#handle_event_run' do
    subject(:assessment) { create(assessment_type) }

    context 'when the assessment has changed but is not valid' do
      before do
        assessment.status = 'foo'
      end

      it 'does not save the assessment' do
        assessment.handle_event_run

        expect(assessment.reload.status).not_to eq('foo')
      end
    end

    context 'when the assessment has changed and is valid' do
      before do
        assessment.status = 'in_progress'
      end

      it 'saves the assessment' do
        assessment.handle_event_run

        expect(assessment.reload.status).to eq('in_progress')
      end
    end
  end

  describe '#editable?' do
    it 'is editable if a move is requested' do
      move = create(:move, :requested, from_location: from_location)
      assessment = create(assessment_type, move: move)

      expect(assessment).to be_editable
    end

    it 'is editable if a move is booked' do
      move = create(:move, :booked, from_location: from_location)
      assessment = create(assessment_type, move: move)

      expect(assessment).to be_editable
    end

    it 'is not editable if a move is not booked or requested' do
      move = create(:move, :in_transit, from_location: from_location)
      assessment = create(assessment_type, move: move)

      expect(assessment).not_to be_editable
    end

    it 'is editable if an assessment is not confirmed' do
      move = create(:move, :booked, from_location: from_location)
      assessment = create(assessment_type, :with_responses, move: move)

      expect(assessment).to be_editable
    end

    it 'is not editable if an assessment is confirmed' do
      move = create(:move, :booked, from_location: from_location)
      assessment = create(assessment_type, :confirmed, :with_responses, move: move)

      expect(assessment).not_to be_editable
    end
  end

  def create_response(options = {})
    question = create(:framework_question, framework: options[:assessmentable].framework, section: options[:section], dependent_value: options[:dependent_value], parent: options[:parent_question])
    create(:string_response, value: options[:value], framework_question: question, assessmentable: options[:assessmentable], responded: options[:responded], parent: options[:parent])
  end
end
