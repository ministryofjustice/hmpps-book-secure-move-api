# frozen_string_literal: true

require 'rails_helper'

module Mock
  # NB: the mock class name must be unique in test suite
  class PaperTrailController < ApiController
    def self.current_user; end

    def current_user
      self.class.current_user
    end

    def authentication_enabled?
      false # NB: disable authentication to simplify tests (it is tested elsewhere)
    end

    def data
      render json: {
        user: user_for_paper_trail,
        info: info_for_paper_trail,
      }
    end
  end
end

RSpec.describe Mock::PaperTrailController, type: :request do
  around do |example|
    Rails.application.routes.draw do
      get '/mock/paper_trail', to: 'mock/paper_trail#data'
    end

    example.run

    Rails.application.reload_routes!
  end

  let(:headers) { {} }

  before do
    allow(described_class).to receive(:current_user).and_return(current_user)
    get '/mock/paper_trail', headers:
  end

  context 'when the current_user does not have an owner (frontend)' do
    let(:current_user) { Doorkeeper::Application.create(name: 'test') }

    context 'when the X-Current-User header is present' do
      let(:headers) { { 'X-Current-User' => 'TEST_USER' } }

      it 'returns user: TEST_USER and supplier_id: nil' do
        expect(response.body).to eq({ user: 'TEST_USER', info: { supplier_id: nil } }.to_json)
      end
    end

    context 'when the X-Current-User header is not present' do
      it 'returns user: nil and supplier_id: nil' do
        expect(response.body).to eq({ user: nil, info: { supplier_id: nil } }.to_json)
      end
    end
  end

  context 'when the current_user does have an owner (supplier)' do
    let(:owner_supplier) { create :supplier }
    let(:current_user) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

    context 'when the X-Current-User header is present' do
      let(:headers) { { 'X-Current-User' => 'TEST_USER' } }

      it 'returns user: TEST_USER and supplier_id: owner_supplier.id' do
        expect(response.body).to eq({ user: 'TEST_USER', info: { supplier_id: owner_supplier.id } }.to_json)
      end
    end

    context 'when the X-Current-User header is not present' do
      it 'returns user: nil and supplier_id: owner_supplier.id' do
        expect(response.body).to eq({ user: nil, info: { supplier_id: owner_supplier.id } }.to_json)
      end
    end
  end
end
