RSpec.shared_examples 'captures a message in Sentry' do
  before { allow(Sentry).to receive(:capture_message) }

  it 'captures a message in Sentry' do
    subject
    expect(Sentry).to have_received(:capture_message).with(sentry_message, sentry_options)
  end
end
