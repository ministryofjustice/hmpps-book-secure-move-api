# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionSerializer do
  subject(:serializer) { described_class.new(subscription) }

  let(:subscription) { create(:subscription) }
  let(:adapter_options) { {} }
  let(:result) do
    JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys
  end

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'subscriptions'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql subscription.id
  end

  it 'contains a first_names attribute' do
    expect(result[:data][:attributes][:callback_url]).to eql 'http://foo.bar/?bla=bla'
  end

  it 'contains a last_name attribute' do
    expect(result[:data][:attributes][:enabled]).to be true
  end

  it 'does not contains a username' do
    expect(result[:data][:attributes][:username]).to be nil
  end

  it 'does not contains a password' do
    expect(result[:data][:attributes][:password]).to be nil
  end

  it 'does not contains a secret' do
    expect(result[:data][:attributes][:secret]).to be nil
  end
end
