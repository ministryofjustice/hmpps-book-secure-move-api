require 'rails_helper'

# TODO: Remove this once we've migrated all profile attributes to a person and are updating these attributes dynamically
RSpec.describe DocumentMover do
  subject(:mover) { described_class.new(document) }

  before do
    allow(document).to receive(:update!).and_call_original
  end

  describe '#call' do
    context 'when we pass in a nil `Document`' do
      let(:document) { nil }

      it "does not update the Document's relationships" do
        result = mover.call

        expect(result).to eq(true)
        expect(document).not_to have_received(:update!)
      end
    end

    context 'when we pass in a `Document` which already has a documentable' do
      let(:document) { create(:document, documentable: profile) }
      let(:profile) { create(:profile) }

      it "does not update the Document's relationships" do
        result = mover.call

        expect(result).to eq(true)
        expect(document).not_to have_received(:update!)
      end
    end

    context 'when we pass in a `Document` without a `Move`' do
      let(:document) { create(:document) }

      it "does not update the Document's relationships" do
        result = mover.call

        expect(result).to eq(true)
        expect(document).not_to have_received(:update!)
      end
    end

    context 'when we pass in a `Document` on a `Move` without a `Profile`' do
      let(:document) { create(:document, move: move) }
      let(:move) { create(:move, profile: profile) }
      let(:profile) { nil }

      it "does not update the Document's relationships" do
        result = mover.call

        expect(result).to eq(true)
        expect(document).not_to have_received(:update!)
      end
    end

    context 'when we pass in a `Document` on a `Move` with a `Profile`' do
      let(:document) { create(:document, move: move) }
      let(:move) { create(:move, profile: profile) }
      let(:profile) { create(:profile) }

      it "updates the Document's relationships" do
        result = mover.call

        expect(result).to eq(true)
        expect(document).to have_received(:update!).with(move: nil, documentable: profile)
      end

      it 'moves the `Document` to the `Profile`' do
        expect { mover.call }.to change { profile.reload.documents.count }.from(0).to(1)
      end

      context 'when we rerun the mover' do
        it 'does not change relationships multiple times' do
          mover.call
          expect { mover.call }.not_to change { profile.reload.documents.count }
        end
      end
    end
  end
end
