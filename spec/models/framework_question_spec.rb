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

  describe '#build_responses' do
    let(:questions) { described_class.all.index_by(&:id) }

    it 'builds a string response for radio questions' do
      question = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response).to be_a(FrameworkResponse::String)
    end

    it 'builds an array response for checkbox questions' do
      question = create(:framework_question, :checkbox)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response).to be_a(FrameworkResponse::Array)
    end

    it 'builds a string response for text questions' do
      question = create(:framework_question, :text)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response).to be_a(FrameworkResponse::String)
    end

    it 'builds a string response for textarea questions' do
      question = create(:framework_question, :textarea)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response).to be_a(FrameworkResponse::String)
    end

    it 'builds an object response for radio with followup questions' do
      question = create(:framework_question, followup_comment: true)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response).to be_a(FrameworkResponse::Object)
    end

    it 'builds a collection response for checkbox with followup questions' do
      question = create(:framework_question, :checkbox, followup_comment: true)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response).to be_a(FrameworkResponse::Collection)
    end

    it 'builds response associated to correct question' do
      question1 = create(:framework_question)
      question2 = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question1.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
        question: question2,
      )

      expect(response.framework_question).to eq(question2)
    end

    it 'builds response associated to correct person_escort_record' do
      question = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response.person_escort_record).to eq(person_escort_record)
    end

    it 'builds response and defaults to current question' do
      question = create(:framework_question)
      person_escort_record = create(:person_escort_record)
      response = question.build_responses(
        person_escort_record: person_escort_record,
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
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response.dependents.size).to eq(2)
    end

    it 'builds response dependents associated to correct dependent question' do
      person_escort_record = create(:person_escort_record)
      question = create(:framework_question)
      dependent_question = create(:framework_question, :checkbox, parent: question)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response.dependents.first.framework_question).to eq(dependent_question)
    end

    it 'sets person_escort_record on dependent responses' do
      person_escort_record = create(:person_escort_record)
      question = create(:framework_question)
      create(:framework_question, :checkbox, parent: question)
      response = question.build_responses(
        person_escort_record: person_escort_record,
        questions: questions,
      )

      expect(response.dependents.first.person_escort_record).to eq(person_escort_record)
    end

    it 'sets correct types on dependent responses' do
      person_escort_record = create(:person_escort_record)
      question = create(:framework_question)
      create(:framework_question, :checkbox, followup_comment: true, parent: question)
      create(:framework_question, :textarea, parent: question)
      response = question.build_responses(
        person_escort_record: person_escort_record,
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
        person_escort_record: person_escort_record,
        questions: questions,
      )

      dependent_responses = response.dependents
      expect(dependent_responses.first.dependents.size).to eq(2)
    end
  end
end
