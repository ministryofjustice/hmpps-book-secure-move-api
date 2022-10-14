# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AllocationsController do
  include ActiveJob::TestHelper

  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let(:resource_to_json) do
    ActiveStorage::Current.host = 'http://www.example.com' # This is used in the serializer
    JSON.parse(AllocationSerializer.new(allocation.reload, include: AllocationSerializer::SUPPORTED_RELATIONSHIPS).serializable_hash.to_json)
  end

  let(:detail_404) { "Couldn't find Move with 'id'=UUID-not-found" }

  describe 'PATCH /allocations' do
    let(:move_params) do
      # expect(result.from_location).to eq(allocation.from_location)
      # expect(result.to_location).to eq(allocation.to_location)
      # expect(result.moves_count).to eq(allocation.moves_count)
      # expect(result.complete_in_full).to eq(allocation.complete_in_full)
      # expect(result.other_criteria).to eq(allocation.other_criteria)
      # expect(result.status).to eq(allocation.status)
      # expect(result.requested_by).to eq(allocation.requested_by)
      # expect(result.estate).to eq(allocation.estate)
      # expect(result.sentence_length_comment).to eq(allocation.sentence_length_comment)
      # expect(result.estate_comment).to eq(allocation.estate_comment)
      {
        type: 'allocations',
        attributes: {
          status: 'requested',
          additional_information: 'some more info',
          cancellation_reason: nil, # NB: cancellation_reason must only be specified if status==cancelled
          cancellation_reason_comment: nil,
          move_type: 'court_appearance',
          move_agreed: true,
          move_agreed_by: 'Fred Bloggs',
          date_from: date_from,
          date_to: date_to,
        },
      }
    end

    let(:schema) { load_yaml_schema('patch_allocation_responses.yaml') }
    let!(:allocation) { create :allocation, :with_5_moves, date: date1 }
    let(:date1) { Date.yesterday }
    let(:date2) { Date.tomorrow }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      do_patch
    end

    context 'when authorized' do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
      let(:access_token) { 'spoofed-token' }

      context 'when successful' do
        let(:result) { allocation.reload }

        it_behaves_like 'an endpoint that responds with success 200'

        it 'updates the date of the allocation' do
          expect(result.date).to eq(date2)
        end

        it 'updates the date of the moves' do
          result.moves.each { |move| expect(move.date).to eq(date2) }
        end

        it 'does not update anything else' do
          expect(result.from_location).to eq(allocation.from_location)
          expect(result.to_location).to eq(allocation.to_location)
          expect(result.moves_count).to eq(allocation.moves_count)
          expect(result.complete_in_full).to eq(allocation.complete_in_full)
          expect(result.other_criteria).to eq(allocation.other_criteria)
          expect(result.status).to eq(allocation.status)
          expect(result.requested_by).to eq(allocation.requested_by)
          expect(result.estate).to eq(allocation.estate)
          expect(result.sentence_length_comment).to eq(allocation.sentence_length_comment)
          expect(result.estate_comment).to eq(allocation.estate_comment)
        end
      end
    end
  end

  def do_patch
    patch "/api/v1/allocations/#{move_id}", params: { data: move_params }, headers: headers, as: :json
  end

  def clean_active_storage_urls(text)
    # this strips the path from test active storage urls, in order to prevent a flaky test in CircleCI
    # e.g. "http://www.example.com/rails/active_storage/disk/XXX/YYY/ZZZ/file-sample_100kB.doc?content_type=AAA&disposition=BBB"
    # ---> "http://www.example.com/file-sample_100kB.doc?content_type=AAA&disposition=BBB"
    text.gsub(/("https?:\/\/www\.example\.com\/)([^"]+)\/([^"]+")/, '\1\3')
  end
end
