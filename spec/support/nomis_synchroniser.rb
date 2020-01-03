# frozen_string_literal: true

RSpec.shared_examples 'it does not trigger NomisSynchroniser' do |_parameter|
  before do |example|
    allow(Moves::NomisSynchroniser).to receive(:new)
    submit_request(example.metadata)
  end

  it 'does not trigger the NomisSynchroniser' do
    expect(Moves::NomisSynchroniser).not_to have_received(:new)
  end
end
