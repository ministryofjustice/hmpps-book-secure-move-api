# frozen_string_literal: true

require 'rails_helper'

module Mock
  # NB: the mock class name must be unique in test suite
  class ValidationController < ApiController
    def authentication_enabled?
      false # NB: disable authentication to simplify tests (it is tested elsewhere)
    end

    def data
      genders = Gender.all
      render_json genders, serializer: GenderSerializer, status: :ok
    end
  end

  class Model
    include ActiveModel::Model

    attr_accessor :name, :status, :email

    validates :name, presence: true
    validates :status, inclusion: { in: %w[requested accepted] }
    validates :email, presence: true
    validates :email, format: { with: /\A\S+@.+\.\S+\z/ }

    validate :name_is_unique

    def self.name
      'Model'
    end

    def existing_id
      1
    end

    def name_is_unique
      errors.add(:name, :taken)
    end
  end
end

RSpec.describe Mock::ValidationController, type: :request do
  context 'with empty body accepts requests with no Content-Type' do
    let(:response_json) { JSON.parse(response.body) }
    let(:schema) { load_yaml_schema('get_genders_responses.yaml') }

    around do |example|
      Rails.application.routes.draw { get '/mock/data', to: 'mock/validation#data' }
      example.run
      Rails.application.reload_routes!
    end

    before { get '/mock/data', headers: }

    it_behaves_like 'an endpoint that responds with success 200'
  end

  describe '#validation_errors' do
    let(:model) { Mock::Model.new }

    let(:errors) do
      [
        {
          title: 'Unprocessable entity',
          detail: "Name can't be blank",
          source: { pointer: '/data/attributes/name' },
          code: :blank,
        },
        {
          title: 'Unprocessable entity',
          detail: 'Name has already been taken',
          source: { pointer: '/data/attributes/name' },
          code: :taken,
          meta: { existing_id: model.existing_id },
        },
        {
          title: 'Unprocessable entity',
          detail: 'Status is not included in the list',
          source: { pointer: '/data/attributes/status' },
          code: :inclusion,
        },
        {
          title: 'Unprocessable entity',
          detail: "Email can't be blank",
          source: { pointer: '/data/attributes/email' },
          code: :blank,
        },
        {
          title: 'Unprocessable entity',
          detail: 'Email is invalid',
          source: { pointer: '/data/attributes/email' },
          code: :invalid,
        },
      ]
    end

    before { model.valid? }

    it 'returns the correct errors' do
      expect(described_class.new.send(:validation_errors, model)).to match errors
    end
  end
end
