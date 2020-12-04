# frozen_string_literal: true

require 'rails_helper'

module Mock
  # NB: the mock class name must be unique in test suite
  class PaginationController < ApiController
    def authentication_enabled?
      false # NB: disable authentication to simplify tests (it is tested elsewhere)
    end

    def data
      paginate Location.all, serializer: LocationSerializer, status: :ok
    end

    def data_with_meta
      paginate Location.all, serializer: LocationSerializer, status: :ok, meta: { foo: 'bar' }
    end

    def data_with_links
      paginate Location.all, serializer: LocationSerializer, status: :ok, links: { foo: 'bar' }
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
      get '/mock/data_with_links', to: 'mock/pagination#data_with_links'
    end

    example.run

    Rails.application.reload_routes!
  end

  describe 'meta' do
    before { create_list :location, 6 }

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

    context 'with custom meta options' do
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

  describe 'links' do
    context 'with data to paginate' do
      before { create_list :location, 6 }

      it 'provides pagination links' do
        get '/mock/data'

        expect(response_json['links']).to include_json(
          {
            self: 'http://www.example.com/mock/data?page=1&per_page=5',
            first: 'http://www.example.com/mock/data?page=1&per_page=5',
            prev: nil,
            next: 'http://www.example.com/mock/data?page=2&per_page=5',
            last: 'http://www.example.com/mock/data?page=2&per_page=5',
          },
        )
      end

      it 'links to previous page' do
        get '/mock/data', params: { page: 2 }

        expect(response_json['links']).to include_json(
          {
            self: 'http://www.example.com/mock/data?page=2&per_page=5',
            first: 'http://www.example.com/mock/data?page=1&per_page=5',
            prev: 'http://www.example.com/mock/data?page=1&per_page=5',
            next: nil,
            last: 'http://www.example.com/mock/data?page=2&per_page=5',
          },
        )
      end

      it 'links to next page' do
        get '/mock/data', params: { per_page: 2 }

        expect(response_json['links']).to include_json(
          {
            self: 'http://www.example.com/mock/data?page=1&per_page=2',
            first: 'http://www.example.com/mock/data?page=1&per_page=2',
            prev: nil,
            next: 'http://www.example.com/mock/data?page=2&per_page=2',
            last: 'http://www.example.com/mock/data?page=3&per_page=2',
          },
        )
      end
    end

    context 'with no data' do
      it 'provides pagination links' do
        get '/mock/data'

        expect(response_json['links']).to include_json(
          {
            self: 'http://www.example.com/mock/data?page=1&per_page=5',
            first: 'http://www.example.com/mock/data?page=1&per_page=5',
            prev: nil,
            next: nil,
            last: 'http://www.example.com/mock/data?page=1&per_page=5',
          },
        )
      end
    end

    context 'with custom links option' do
      before { get '/mock/data_with_links' }

      it 'includes pagination links' do
        expect(response_json['links']['self']).to be_present
      end

      it 'includes custom links' do
        expect(response_json['links']['foo']).to eq 'bar'
      end
    end
  end
end
