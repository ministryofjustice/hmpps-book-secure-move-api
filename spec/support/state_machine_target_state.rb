RSpec.shared_examples 'state_machine target state' do |expected_state|
  describe 'machine state' do
    it { expect(machine.current).to eql expected_state }
  end

  describe 'target state' do
    it { expect(target.state).to eql expected_state }
  end
end
