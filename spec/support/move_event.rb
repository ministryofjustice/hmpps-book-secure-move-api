RSpec.shared_examples 'a move event' do
  it 'validates eventable_type' do
    expect(generic_event).to validate_inclusion_of(:eventable_type).in_array(%w[Move])
  end
end
