RSpec.shared_examples 'state_machine target status' do |expected_status|
  describe 'machine status' do
    it { expect(machine.current).to eql expected_status }
  end

  describe 'target status' do
    it { expect(target.status).to eql expected_status }
  end
end
