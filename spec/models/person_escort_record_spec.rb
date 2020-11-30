# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecord do
  it_behaves_like 'a framework assessment', :person_escort_record, described_class

  describe '#editable' do
    it 'is editable if a move is requested' do
      move = create(:move, :requested)
      person_escort_record = create(:person_escort_record, move: move)

      expect(person_escort_record.editable).to eq(true)
    end

    it 'is editable if a move is booked' do
      move = create(:move, :booked)
      person_escort_record = create(:person_escort_record, move: move)

      expect(person_escort_record.editable).to eq(true)
    end

    it 'is not editable if a move is not booked or requested' do
      move = create(:move, :in_transit)
      person_escort_record = create(:person_escort_record, move: move)

      expect(person_escort_record.editable).to eq(false)
    end

    it 'is editable if a PER is not confirmed' do
      move = create(:move, :booked)
      person_escort_record = create(:person_escort_record, :with_responses, move: move)

      expect(person_escort_record.editable).to eq(true)
    end

    it 'is not editable if a PER is confirmed' do
      move = create(:move, :booked)
      person_escort_record = create(:person_escort_record, :confirmed, :with_responses, move: move)

      expect(person_escort_record.editable).to eq(false)
    end

    context 'when no move associated' do
      it 'is editable if a PER is not confirmed' do
        person_escort_record = create(:person_escort_record, :with_responses, move: nil)

        expect(person_escort_record.editable).to eq(true)
      end

      it 'is not editable if a PER is confirmed' do
        person_escort_record = create(:person_escort_record, :confirmed, :with_responses, move: nil)

        expect(person_escort_record.editable).to eq(false)
      end
    end
  end
end
