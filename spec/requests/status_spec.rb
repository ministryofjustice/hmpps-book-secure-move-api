# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Status', type: :request do
  let(:build_number) { '2026-11-25.123.abc1234' }
  let(:git_ref) { 'abc1234def5678' }

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

  describe 'GET /ping with the standard build variables' do
    around do |example|
      ClimateControl.modify(
        'BUILD_NUMBER' => build_number,
        'GIT_REF' => git_ref,
        'APP_BUILD_TAG' => '',
        'APP_GIT_COMMIT' => '',
      ) do
        example.run
      end
    end

    before { get '/ping' }

    it 'returns the build number and commit' do
      expect(JSON.parse(response.body)).to include(
        'build_tag' => build_number,
        'commit_id' => git_ref,
      )
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

    around do |example|
      ClimateControl.modify('BUILD_NUMBER' => build_number, 'GIT_REF' => git_ref) do
        example.run
      end
    end

    context 'with working database connection' do
      before { get '/health' }

      it_behaves_like 'database', 'OK'
      it_behaves_like 'overall health', 'OK'

      it 'returns status OK' do
        expect(response.code).to eq '200'
      end

      it 'returns the health and build details' do
        expect(response_hash).to include(
          'status' => 'UP',
          'components' => { 'db' => { 'status' => 'UP' } },
          'build' => { 'buildNumber' => build_number, 'gitRef' => git_ref },
          'version' => build_number,
        )
      end

      it 'returns the uptime in whole seconds' do
        expect(response_hash['uptime']).to be_a(Integer)
      end
    end

    context 'with no working database connection' do
      before do
        allow(ActiveRecord::Base).to receive(:with_connection).and_raise(StandardError.new('Database connection failed'))
        get '/health'
      end

      it_behaves_like 'database', 'not OK'
      it_behaves_like 'overall health', 'not OK'

      it 'returns status Service Unavailable' do
        expect(response.code).to eq '503'
      end

      it 'reports the database and overall status as DOWN' do
        expect(response_hash).to include(
          'status' => 'DOWN',
          'components' => { 'db' => { 'status' => 'DOWN' } },
        )
      end
    end
  end

  describe 'GET /info' do
    let(:response_hash) { JSON.parse(response.body) }

    context 'when the build variables are set' do
      around do |example|
        ClimateControl.modify(
          'BUILD_NUMBER' => build_number,
          'GIT_REF' => git_ref,
          'GIT_BRANCH' => 'main',
          'PRODUCT_ID' => 'DPS003',
        ) do
          example.run
        end
      end

      before { get '/info' }

      it 'returns status OK' do
        expect(response.code).to eq '200'
      end

      it 'returns the build details' do
        expect(response_hash).to include(
          'git' => { 'branch' => 'main', 'commit' => { 'id' => git_ref } },
          'build' => {
            'artifact' => 'hmpps-book-secure-move-api',
            'name' => 'hmpps-book-secure-move-api',
            'version' => build_number,
          },
          'productId' => 'DPS003',
        )
      end
    end

    context 'when only the older APP_* variables are set' do
      around do |example|
        ClimateControl.modify(
          'BUILD_NUMBER' => '',
          'GIT_REF' => '',
          'APP_BUILD_TAG' => 'old-build-tag',
          'APP_GIT_COMMIT' => 'old-commit',
        ) do
          example.run
        end
      end

      before { get '/info' }

      it 'falls back to the older variables' do
        expect(response_hash['build']['version']).to eq 'old-build-tag'
        expect(response_hash['git']['commit']['id']).to eq 'old-commit'
      end
    end
  end
end
