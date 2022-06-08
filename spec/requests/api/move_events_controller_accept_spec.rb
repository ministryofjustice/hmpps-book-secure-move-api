# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MoveEventsController do
  subject(:do_post) do
    post("/api/v1/moves/#{move_id}/accept", params: params, headers: headers, as: :json)
  end

  describe 'POST /moves/:move_id/accept' do
    include_context 'with supplier with spoofed access token'

    let(:from_location) { create(:location, suppliers: [supplier]) }
    let(:move) { create(:move, :requested, from_location: from_location) }
    let(:move_id) { move.id }

    context 'with happy params' do
      let(:params) do
        {
          data: {
            type: 'accepts',
            attributes: {
              timestamp: '2020-04-23T18:25:43.511Z',
              notes: 'something noteworthy',
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 204' do
        before do
          do_post
        end
      end

      it 'changes the move to booked' do
        do_post
        expect(move.reload).to be_booked
      end

      it 'writes a move accept event' do
        expect { do_post }.to change(GenericEvent::MoveAccept, :count).by(1)
      end
    end

    context 'with unhappy params' do
      let(:params) { { foo: 'bar' } }

      it_behaves_like 'an endpoint that responds with error 400' do
        before do
          do_post
        end
      end
    end
  end
end
