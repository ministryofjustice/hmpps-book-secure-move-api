# frozen_string_literal: true

require 'rails_helper'

module Mock
  # NB: the mock class name must be unique in test suite
  class PaginationController < ApiController
    def authentication_enabled?
      false # NB: disable authentication to simplify tests (it is tested elsewhere)
    end

    def data
      paginate Location.all, status: :ok
    end

    def data_with_meta
      paginate Location.all, status: :ok, meta: { foo: 'bar' }
    end
  end
end

RSpec.describe Mock::PaginationController, type: :request do
  let(:response_json) { JSON.parse(response.body) }
  let(:params) { {} }

  around do |example|
    Rails.application.routes.draw do
      get '/mock/data', to: 'mock/pagination#data'
      get '/mock/data_with_meta', to: 'mock/pagination#data_with_meta'
    end

    example.run

    Rails.application.reload_routes!
  end

  before do
    create_list :location, 6
  end

  context 'with no pagination parameters' do
    before { get '/mock/data' }

    it 'paginates 5 results per page' do
      expect(response_json['data'].size).to eq 5
    end

    it 'provides meta data with pagination' do
      expect(response_json['meta']['pagination']).to include_json(
        {
          per_page: 5,
          total_pages: 2,
          total_objects: 6,
        },
      )
    end
  end

  context 'with custom meta parameters' do
    before { get '/mock/data_with_meta' }

    it 'includes pagination meta data' do
      expect(response_json['meta']['pagination']).to be_present
    end

    it 'includes custom meta data' do
      expect(response_json['meta']['foo']).to eq 'bar'
    end
  end

  context 'with page parameter' do
    before { get '/mock/data', params: { page: 2 } }

    it 'returns 1 result on the second page' do
      expect(response_json['data'].size).to eq 1
    end
  end

  context 'with per_page parameter' do
    before { get '/mock/data', params: { per_page: 2 } }

    it 'allows setting a different page size' do
      expect(response_json['data'].size).to eq 2
    end
  end
end
