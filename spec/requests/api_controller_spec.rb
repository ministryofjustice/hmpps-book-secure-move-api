# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiController, type: :request do
  subject(:api_controller) { described_class.new }

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
