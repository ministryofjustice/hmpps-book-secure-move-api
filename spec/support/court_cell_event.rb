RSpec.shared_examples 'a court cell event' do
  it { is_expected.to validate_presence_of(:court_cell_number) }
end
