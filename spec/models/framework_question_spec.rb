# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkQuestion do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:section) }
  it { is_expected.to validate_presence_of(:question_type) }
  it { is_expected.to validate_inclusion_of(:question_type).in_array(%w[radio checkbox text textarea add_multiple_items]) }

  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:parent).optional }

  it { is_expected.to have_many(:dependents) }
  it { is_expected.to have_many(:framework_flags) }
  it { is_expected.to have_many(:framework_responses) }
  it { is_expected.to have_and_belong_to_many(:framework_nomis_codes) }

  describe '#build_responses' do
    let(:questions) { described_class.all.index_by(&:id) }

    it 'builds response associated to correct question' do
      question1 = create(:framework_question)
      question2 = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question1.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
        question: question2,
      )

      expect(response.framework_question).to eq(question2)
    end

    it 'builds response associated to correct assessment' do
      question = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
      )

      expect(response.assessmentable).to eq(person_escort_record)
    end

    it 'builds response and defaults to current question' do
      question = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
      )

      expect(response.framework_question).to eq(question)
    end

    it 'builds response dependents if question is dependent' do
      person_escort_record = create(:person_escort_record)
      question = create(:framework_question)
      create(:framework_question, :checkbox, parent: question)
      create(:framework_question, :textarea, parent: question)
      response = question.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
      )

      expect(response.dependents.size).to eq(2)
    end

    it 'builds response dependents associated to correct dependent question' do
      person_escort_record = create(:person_escort_record)
      question = create(:framework_question)
      dependent_question = create(:framework_question, :checkbox, parent: question)
      response = question.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
      )

      expect(response.dependents.first.framework_question).to eq(dependent_question)
    end

    it 'does not build dependent responses for multiple item questions' do
      person_escort_record = create(:person_escort_record)
      question = create(:framework_question, :add_multiple_items)
      response = question.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
      )

      expect(response.dependents).to be_empty
    end

    it 'sets assessment on dependent responses' do
      person_escort_record = create(:person_escort_record)
      question = create(:framework_question)
      create(:framework_question, :checkbox, parent: question)
      response = question.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
      )

      expect(response.dependents.first.assessmentable).to eq(person_escort_record)
    end

    it 'sets correct types on dependent responses' do
      person_escort_record = create(:person_escort_record)
      question = create(:framework_question)
      create(:framework_question, :checkbox, followup_comment: true, parent: question)
      create(:framework_question, :textarea, parent: question)
      response = question.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
      )

      expect(response.dependents.map(&:type)).to contain_exactly(
        'FrameworkResponse::Collection',
        'FrameworkResponse::String',
      )
    end

    it 'builds response with multiple levels of nested dependent responses' do
      person_escort_record = create(:person_escort_record)
      parent_question = create(:framework_question, :textarea)
      child_question = create(:framework_question, :checkbox, followup_comment: true, parent: parent_question)
      create(:framework_question, parent: child_question)
      create(:framework_question, parent: child_question)
      response = parent_question.build_responses(
        assessmentable: person_escort_record,
        questions: questions,
      )

      dependent_responses = response.dependents
      expect(dependent_responses.first.dependents.size).to eq(2)
    end

    context 'with previous_responses' do
      it 'builds response with correct value' do
        question1 = create(:framework_question)
        question2 = create(:framework_question)
        previous_responses = {
          question1.key => 'Yes',
          question2.key => 'No',
        }
        person_escort_record = create(:person_escort_record)
        response = question1.build_responses(
          assessmentable: person_escort_record,
          questions: questions,
          question: question2,
          previous_responses: previous_responses,
        )

        expect(response.value).to eq('No')
      end

      it 'builds response dependents with correct value' do
        person_escort_record = create(:person_escort_record)
        question = create(:framework_question)
        dependent_question = create(:framework_question, :checkbox, parent: question)
        previous_responses = {
          question.key => 'Yes',
          dependent_question.key => ['Level 1'],
        }
        response = question.build_responses(
          assessmentable: person_escort_record,
          questions: questions,
          previous_responses: previous_responses,
        )

        expect(response.dependents.first.value).to contain_exactly('Level 1')
      end

      it 'sets prefilled value on dependents' do
        person_escort_record = create(:person_escort_record)
        question = create(:framework_question)
        dependent_question = create(:framework_question, :checkbox, parent: question)
        previous_responses = {
          question.key => 'Yes',
          dependent_question.key => ['Level 1'],
        }
        response = question.build_responses(
          assessmentable: person_escort_record,
          questions: questions,
          previous_responses: previous_responses,
        )

        expect(response.dependents.first).to be_prefilled
      end

      it 'builds response for multiple item question with correct value' do
        person_escort_record = create(:person_escort_record)
        question = create(:framework_question, :add_multiple_items)
        value = [{ 'item' => 1, 'responses' => [{ 'value' => ['Level 1'], 'framework_question_id' => question.dependents.first.id }] }.with_indifferent_access]
        previous_responses = {
          question.key => value,
        }
        response = question.build_responses(
          assessmentable: person_escort_record,
          questions: questions,
          previous_responses: previous_responses,
        )

        expect(response.value).to eq(value)
      end
    end
  end

  describe '#build_response' do
    it 'builds a string response for radio questions' do
      question = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question.build_response(
        question,
        person_escort_record,
      )

      expect(response).to be_a(FrameworkResponse::String)
    end

    it 'builds an array response for checkbox questions' do
      question = create(:framework_question, :checkbox)
      person_escort_record = create(:person_escort_record)
      response = question.build_response(
        question,
        person_escort_record,
      )

      expect(response).to be_a(FrameworkResponse::Array)
    end

    it 'builds a string response for text questions' do
      question = create(:framework_question, :text)
      person_escort_record = create(:person_escort_record)
      response = question.build_response(
        question,
        person_escort_record,
      )

      expect(response).to be_a(FrameworkResponse::String)
    end

    it 'builds a string response for textarea questions' do
      question = create(:framework_question, :textarea)
      person_escort_record = create(:person_escort_record)
      response = question.build_response(
        question,
        person_escort_record,
      )

      expect(response).to be_a(FrameworkResponse::String)
    end

    it 'builds an object response for radio with followup questions' do
      question = create(:framework_question, followup_comment: true)
      person_escort_record = create(:person_escort_record)
      response = question.build_response(
        question,
        person_escort_record,
      )

      expect(response).to be_a(FrameworkResponse::Object)
    end

    it 'builds a collection response for checkbox with followup questions' do
      question = create(:framework_question, :checkbox, followup_comment: true)
      person_escort_record = create(:person_escort_record)
      response = question.build_response(
        question,
        person_escort_record,
      )

      expect(response).to be_a(FrameworkResponse::Collection)
    end

    it 'builds a collection response for multiple items questions' do
      question = create(:framework_question, :add_multiple_items)
      person_escort_record = create(:person_escort_record)
      response = question.build_response(
        question,
        person_escort_record,
      )

      expect(response).to be_a(FrameworkResponse::Collection)
    end

    it 'sets prefilled value to false if no value set' do
      question = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question.build_response(
        question,
        person_escort_record,
      )

      expect(response).not_to be_prefilled
    end

    context 'with previous response value' do
      it 'builds a response with the value set' do
        question = create(:framework_question)
        person_escort_record = create(:person_escort_record)
        response = question.build_response(
          question,
          person_escort_record,
          'Yes',
        )

        expect(response.value).to eq('Yes')
      end

      it 'sets prefilled value to true' do
        question = create(:framework_question)
        person_escort_record = create(:person_escort_record)
        response = question.build_response(
          question,
          person_escort_record,
          'Yes',
        )

        expect(response).to be_prefilled
      end

      it 'sets prefilled value to false if empty value supplied' do
        question = create(:framework_question, :checkbox, followup_comment: true)
        person_escort_record = create(:person_escort_record)
        response = question.build_response(
          question,
          person_escort_record,
          [],
        )

        expect(response).not_to be_prefilled
      end
    end
  end

  describe '#response_type' do
    context 'when question is of type radio with followup_comments' do
      let(:framework_question) { create(:framework_question, followup_comment: true) }

      it 'returns response_type `object`' do
        expect(framework_question.response_type).to eq('object::followup_comment')
      end
    end

    context 'when response is of type radio' do
      let(:framework_question) { create(:framework_question) }

      it 'returns response_type `string`' do
        expect(framework_question.response_type).to eq('string')
      end
    end

    context 'when question is of type checkbox with followup_comments' do
      let(:framework_question) { create(:framework_question, :checkbox, followup_comment: true) }

      it 'returns response_type `collection`' do
        expect(framework_question.response_type).to eq('collection::followup_comment')
      end
    end

    context 'when question is of type checkbox' do
      let(:framework_question) { create(:framework_question, :checkbox) }

      it 'returns response_type `array`' do
        expect(framework_question.response_type).to eq('array')
      end
    end

    context 'when question is of type `add_multiple_items`' do
      let(:framework_question) { create(:framework_question, :add_multiple_items) }

      it 'returns response_type `collection::add_multiple_items`' do
        expect(framework_question.response_type).to eq('collection::add_multiple_items')
      end
    end

    context 'when question is of type text' do
      let(:framework_question) { create(:framework_question, :text) }

      it 'returns response_type `string`' do
        expect(framework_question.response_type).to eq('string')
      end
    end
  end
end
