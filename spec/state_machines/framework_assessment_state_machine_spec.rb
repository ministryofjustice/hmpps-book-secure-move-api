# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkAssessmentStateMachine do
  let(:machine) { described_class.new(target) }
  let(:target) { Struct.new(:status, :confirmed_at, :completed_at, :amended_at).new(initial_status) }
  let(:initial_status) { :unstarted }

  before { machine.restore!(initial_status) }

  it { is_expected.to respond_to(:calculate, :confirm) }

  context 'when in the unstarted status' do
    it_behaves_like 'state_machine target status', :unstarted

    context 'when the calculate event is fired and it is in progress' do
      before { machine.calculate(FrameworkAssessmentable::ASSESSMENT_IN_PROGRESS) }

      it_behaves_like 'state_machine target status', :in_progress
    end

    context 'when the complete event is fired and it is completed' do
      before { machine.calculate(FrameworkAssessmentable::ASSESSMENT_COMPLETED) }

      it_behaves_like 'state_machine target status', :completed
    end
  end

  context 'when in the in_progress status' do
    let(:initial_status) { :in_progress }

    it_behaves_like 'state_machine target status', :in_progress

    context 'when the calculate event is fired and it is in progress' do
      before { machine.calculate(FrameworkAssessmentable::ASSESSMENT_IN_PROGRESS) }

      it_behaves_like 'state_machine target status', :in_progress
    end

    context 'when the complete event is fired and it is completed' do
      before { machine.calculate(FrameworkAssessmentable::ASSESSMENT_COMPLETED) }

      it_behaves_like 'state_machine target status', :completed
    end
  end

  context 'when in the completed status' do
    let(:initial_status) { :completed }

    it_behaves_like 'state_machine target status', :completed

    context 'when the calculate event is fired and it is in progress' do
      before { machine.calculate(FrameworkAssessmentable::ASSESSMENT_IN_PROGRESS) }

      it_behaves_like 'state_machine target status', :in_progress
    end

    context 'when the complete event is fired and it is completed' do
      let(:current_timestamp) { Time.zone.now }

      before do
        allow(Time).to receive(:now).and_return(current_timestamp)
        machine.calculate(FrameworkAssessmentable::ASSESSMENT_COMPLETED)
      end

      it_behaves_like 'state_machine target status', :completed

      it 'sets the current timestamp to completed_at' do
        expect(target.completed_at).to eq(current_timestamp)
      end

      it 'maintains first completed at timestamp and does not update it' do
        new_completed_at_timstamp = Time.zone.now + 1.day
        allow(Time).to receive(:now).and_return(new_completed_at_timstamp)
        machine.calculate(FrameworkAssessmentable::ASSESSMENT_COMPLETED)

        expect(target.completed_at).to eq(current_timestamp)
      end

      it 'does not set amended_at timestamp when first completed' do
        expect(target.amended_at).to be_nil
      end

      it 'sets amended_at timestamp when completed again' do
        machine.calculate(FrameworkAssessmentable::ASSESSMENT_COMPLETED)

        expect(target.amended_at).to eq(current_timestamp)
      end
    end

    context 'when the confirm event is fired' do
      let(:current_timestamp) { Time.zone.now }

      before do
        allow(Time).to receive(:now).and_return(current_timestamp)
        machine.confirm
      end

      it_behaves_like 'state_machine target status', :confirmed

      it 'sets the current timestamp to confirmed_at' do
        expect(target.confirmed_at).to eq(current_timestamp)
      end
    end
  end

  context 'when in the confirmed status' do
    let(:initial_status) { :confirmed }

    it_behaves_like 'state_machine target status', :confirmed
  end
end
