# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Status', type: :request do
  describe 'GET /ping' do
    context 'when the correct environment variables have been set during the deploy process' do
      let(:build_date) { '2017-04-06T14:47:13+0000' }
      let(:build_tag) { 'my-build-tag-123XYZ' }
      let(:git_commit) { 'my-commit-123XYZ' }

      around do |example|
        ClimateControl.modify(
          'APP_BUILD_DATE' => build_date,
          'APP_BUILD_TAG' => build_tag,
          'APP_GIT_COMMIT' => git_commit,
        ) do
          example.run
        end
      end

      before { get '/ping' }

      it 'returns json containing the applications version information' do
        expect(response.body).to eq(
          { build_date:,
            commit_id: git_commit,
            build_tag: }.to_json,
        )
      end

      it 'returns status OK' do
        expect(response.code).to eq '200'
      end
    end

    context 'when the environment variables are not present' do
      before { get '/ping' }

      it 'returns an empty json object' do
        expect(response.body).to eq(
          { build_date: StatusController::NOT_AVAILABLE,
            commit_id: StatusController::NOT_AVAILABLE,
            build_tag: StatusController::NOT_AVAILABLE }.to_json,
        )
      end

      it 'returns status OK' do
        expect(response.code).to eq '200'
      end
    end
  end

  describe 'GET /health' do
    let(:response_hash) { JSON.parse(response.body) }
    let(:database_status) { response_hash['checks']['database'] }
    let(:health_status) { response_hash['healthy'] }

    shared_examples 'database' do |expected|
      it "indicates database #{expected}" do
        expect(database_status).to eq(expected == 'OK')
      end
    end

    shared_examples 'overall health' do |expected|
      it "indicates overall health #{expected}" do
        expect(health_status).to eq(expected == 'OK')
      end
    end

    context 'with working database connection' do
      before { get '/health' }

      it_behaves_like 'database', 'OK'
      it_behaves_like 'overall health', 'OK'
    end

    context 'with no working database connection' do
      before do
        allow(ActiveRecord::Base).to receive(:with_connection).and_raise(StandardError.new('Database connection failed'))
        get '/health'
      end

      it_behaves_like 'database', 'not OK'
      it_behaves_like 'overall health', 'not OK'
    end
  end
end
