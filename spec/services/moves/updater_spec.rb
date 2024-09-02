# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Updater do
  subject(:updater) { described_class.new(move, move_params) }

  let(:before_documents) { create_list(:document, 2) }
  let(:supplier) { create(:supplier) }
  let!(:from_location) { create(:location, :police) }
  let!(:move) { create(:move, :proposed, :prison_recall, from_location:, profile:, supplier:) }
  let(:profile) { create(:profile, documents: before_documents) }
  let(:date_from) { Date.yesterday }
  let(:date_to) { Date.tomorrow }
  let(:date) { Time.zone.today }
  let(:status) { 'requested' }
  let(:cancellation_reason) { nil }

  let(:move_params) do
    {
      type: 'moves',
      attributes: {
        status:,
        additional_information: 'some more info',
        cancellation_reason:,
        cancellation_reason_comment: nil,
        move_agreed: true,
        move_agreed_by: 'Fred Bloggs',
        date_from:,
        date_to:,
        date:,
      },
    }
  end

  context 'with valid params' do
    it 'updates the correct attributes on an existing move' do
      updater.call
      expect(updater.move).to have_attributes(
        status: 'requested',
        additional_information: 'some more info',
        move_agreed: true,
        move_agreed_by: 'Fred Bloggs',
        date_from:,
        date_to:,
      )
    end

    context 'when status changes without an associated allocation' do
      it 'sets `status_changed` to `true`' do
        updater.call
        expect(updater.status_changed).to be_truthy
      end
    end

    context 'when status changes to cancelled with an associated allocation' do
      let!(:allocation) { create :allocation, moves_count: 5 }
      let!(:move) { create :move, :requested, from_location:, allocation:, date: }

      let(:cancellation_reason) { 'other' }
      let(:status) { 'cancelled' }

      it 'corrects allocation moves_count' do
        expect { updater.call }.to change { move.allocation.reload.moves_count }.from(5).to(0)
      end
    end

    context 'when dates changes with an associated allocation' do
      let(:allocation) { create :allocation, moves_count: 5 }
      let(:move) { create :move, :requested, allocation: }

      it 'fails to update the date' do
        expect { updater.call }.to raise_error(ActiveRecord::RecordInvalid, /cannot be changed as move is part of an allocation/)
      end
    end

    context 'when status is not updated' do
      let(:status) { 'proposed' }

      it 'sets `status_changed` to `false`' do
        updater.call
        expect(updater.status_changed).to be_falsey
      end
    end

    context 'when date changes' do
      let(:date) { '2019-08-23' }

      it 'sets `date_changed` to `true`' do
        updater.call
        expect(updater.date_changed).to be true
      end
    end

    context 'when date is not updated' do
      let(:date) { move.date }

      it 'sets `date_changed` to `false`' do
        updater.call
        expect(updater.date_changed).to be false
      end
    end

    context 'with allocation' do
      let(:person) { create(:person) }

      context 'with a move linked to a person' do
        let!(:move) { create(:move, :requested, :with_allocation, profile: nil) }
        let(:move_params) do
          {
            type: 'moves',
            relationships: { person: { data: { id: person.id, type: 'people' } } },
          }
        end

        it 'sets the allocation status to filled' do
          expect { updater.call }.to change { move.reload.allocation.status }.to('filled')
        end
      end

      context 'with a move unlinked to a person' do
        let!(:move) { create(:move, :requested, allocation:) }
        let!(:allocation) { create(:allocation, :filled) }
        let(:move_params) do
          {
            type: 'moves',
            relationships: { person: { data: nil } },
          }
        end

        it 'sets the allocation status to unfilled' do
          expect { updater.call }.to change { move.reload.allocation.status }.to('unfilled')
        end
      end

      context 'with a move linked to a profile' do
        let!(:move) { create(:move, :requested, :with_allocation, profile: nil) }
        let(:profile) { create(:profile) }
        let(:move_params) do
          {
            type: 'moves',
            relationships: { profile: { data: { id: profile.id, type: 'profiles' } } },
          }
        end

        it 'sets the allocation status to filled' do
          expect { updater.call }.to change { move.reload.allocation.status }.to('filled')
        end
      end

      context 'with a move unlinked to a profile' do
        let!(:move) { create(:move, :requested, allocation:) }
        let!(:allocation) { create(:allocation, :filled) }
        let(:move_params) do
          {
            type: 'moves',
            relationships: { profile: { data: nil } },
          }
        end

        it 'sets the allocation status to unfilled' do
          expect { updater.call }.to change { move.reload.allocation.status }.to('unfilled')
        end
      end

      context 'with a move profile or status unchanged' do
        let!(:move) { create(:move, :requested, allocation:) }
        let!(:allocation) { create(:allocation, :filled) }

        let(:move_params) do
          {
            type: 'moves',
            attributes: {
              additional_information: 'some more info',
            },
          }
        end

        it 'does not change the status' do
          expect { updater.call }.not_to(change { move.reload.allocation.status })
        end
      end

      context 'with a move cancelled' do
        let!(:move) { create(:move, :requested, allocation:, date:) }
        let!(:allocation) { create(:allocation, :filled) }
        let(:status) { 'cancelled' }
        let(:cancellation_reason) { 'other' }

        it 'sets the allocation status to unfilled' do
          expect { updater.call }.to change { move.reload.allocation.status }.to('unfilled')
        end
      end
    end

    context 'with people' do
      let(:before_person) { create(:person) }
      let(:after_person) { create(:person) }
      let!(:move) { create(:move, profile: before_person.latest_profile) }

      context 'with new person' do
        let(:move_params) do
          {
            type: 'moves',
            relationships: { person: { data: { id: after_person.id, type: 'people' } } },
          }
        end

        it 'updates person association to new person' do
          expect { updater.call }.to change { move.reload.profile.person }.from(before_person).to(after_person)
        end
      end

      context 'with empty person data' do
        let(:move_params) do
          {
            type: 'moves',
            relationships: { person: { data: nil } },
          }
        end

        it 'removes associated profile' do
          expect { updater.call }.to change { move.reload.profile }.to(nil)
        end
      end

      context 'with no person relationship' do
        it 'does not change old person associated' do
          expect { updater.call }.not_to(change { move.reload.profile.person })
        end
      end
    end

    context 'with profile' do
      let(:before_profile) { create(:profile) }
      let(:after_profile) { create(:profile) }
      let!(:move) { create(:move, profile: before_profile) }

      context 'with new profile' do
        let(:move_params) do
          {
            type: 'moves',
            relationships: { profile: { data: { id: after_profile.id, type: 'profiles' } } },
          }
        end

        it 'updates profile association to new profile' do
          expect { updater.call }.to change { move.reload.profile }.from(before_profile).to(after_profile)
        end
      end

      context 'with empty profile data' do
        let(:move_params) do
          {
            type: 'moves',
            relationships: { profile: { data: nil } },
          }
        end

        it 'removes associated profile' do
          expect { updater.call }.to change { move.reload.profile }.to(nil)
        end
      end

      context 'with no profile relationship' do
        it 'does not change old profile associated' do
          expect { updater.call }.not_to(change { move.reload.profile })
        end
      end
    end

    context 'with documents' do
      context 'with new documents' do
        let(:after_documents) { create_list(:document, 2) }
        let(:move_params) do
          documents = after_documents.map { |d| { id: d.id, type: 'documents' } }
          {
            type: 'moves',
            relationships: { documents: { data: documents } },
          }
        end

        it 'updates documents association to new documents' do
          updater.call
          expect(updater.move.profile.documents).to match_array(after_documents)
        end
      end

      context 'with empty documents' do
        let(:move_params) do
          {
            type: 'moves',
            relationships: { documents: { data: [] } },
          }
        end

        it 'unsets associated documents' do
          updater.call
          expect(updater.move.profile.documents).to be_empty
        end
      end

      context 'with nil documents' do
        let(:move_params) do
          {
            type: 'moves',
            relationships: { documents: { data: nil } },
          }
        end

        it 'does nothing to existing documents' do
          updater.call
          expect(updater.move.profile.documents).to match_array(before_documents)
        end
      end

      context 'with no document relationship' do
        it 'does nothing to existing documents' do
          updater.call
          expect(updater.move.profile.documents).to match_array(before_documents)
        end
      end
    end
  end

  context 'with invalid input params' do
    let(:status) { 'wrong status' }

    it 'raises an error' do
      expect { updater.call }.to raise_error(ActiveModel::ValidationError)
    end
  end
end
