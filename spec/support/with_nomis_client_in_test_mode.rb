# frozen_string_literal: true

RSpec.shared_context 'with NomisClient in test-mode', shared_context: :metadata do
  before do
    allow(File).to receive(:read).and_return(erb_test_fixture)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('NOMIS_TEST_MODE').and_return('true')
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'with NomisClient in test-mode', with_nomis_client_test_mode: true
end
