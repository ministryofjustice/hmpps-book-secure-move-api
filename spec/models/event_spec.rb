require 'rails_helper'

RSpec.describe Event, type: :model do
  subject(:event) { build(:event) }

  it { is_expected.to belong_to(:eventable) }
  it { is_expected.to validate_presence_of(:eventable) }
  it { is_expected.to validate_presence_of(:event_name) }
  it { is_expected.to validate_presence_of(:client_timestamp) }
  it { is_expected.to validate_presence_of(:details) }
  it { expect(described_class).to respond_to(:default_order) }

  it 'validates event_name' do
    expect(described_class.new).to validate_inclusion_of(:event_name).in_array(%w[
      create update cancel uncancel complete uncomplete redirect start lockout lodging reject
    ])
  end

  describe 'supplier_id' do
    it { expect(event.supplier_id).to eql('1234') }
  end

  describe 'event_params' do
    it { expect(event.event_params).to eql({ 'attributes' => { 'notes' => 'foo' } }) }
  end

  describe 'data_params' do
    it { expect(event.data_params).to eql({ 'attributes' => { 'notes' => 'bar' } }) }
  end

  describe 'notes' do
    it { expect(event.notes).to eql('foo') }
  end

  context 'with locations' do
    subject(:event) { build(:event, :locations) }

    describe 'from_location' do
      it { expect(event.from_location).not_to be nil }
      it { expect(event.from_location).to be_a Location }
    end

    describe 'to_location' do
      it { expect(event.to_location).not_to be nil }
      it { expect(event.to_location).to be_a Location }
    end
  end
end
