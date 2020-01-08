# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiController, type: :request, with_client_authentication: true do
  subject(:api_controller) { described_class.new }

  let!(:application) { Doorkeeper::Application.create(name: 'test') }

  context 'when with empty body accepts requests with no Content-Type' do
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
    let(:content_type) { ApiController::CONTENT_TYPE }
    let(:api_endpoint) { '/api/v1/reference/genders' }
    let(:response_json) { JSON.parse(response.body) }
    let(:schema) { load_json_schema('get_genders_responses.json') }

    before do
      get api_endpoint, headers: headers
    end

    it_behaves_like 'an endpoint that responds with success 200'
  end

  class Model
    include ActiveModel::Model

    attr_accessor :name, :status, :email

    validates :name, presence: true
    validates :status, inclusion: { in: %w[requested accepted] }
    validates :email, presence: true
    validates :email, format: { with: /\A\S+@.+\.\S+\z/ }
  end

  describe '#validation_errors' do
    let(:model) { Model.new }

    let(:errors) do
      [
        {
          title: 'Unprocessable entity',
          detail: "Name can't be blank",
          source: { pointer: '/data/attributes/name' },
          code: :blank
        },
        {
          title: 'Unprocessable entity',
          detail: 'Status is not included in the list',
          source: { pointer: '/data/attributes/status' },
          code: :inclusion
        },
        {
          title: 'Unprocessable entity',
          detail: "Email can't be blank",
          source: { pointer: '/data/attributes/email' },
          code: :blank
        },
        {
          title: 'Unprocessable entity',
          detail: 'Email is invalid',
          source: { pointer: '/data/attributes/email' },
          code: :invalid
        }
      ]
    end

    before { model.valid? }

    it 'returns the correct errors' do
      expect(api_controller.send(:validation_errors, model.errors)).to eq errors
    end
  end
end
