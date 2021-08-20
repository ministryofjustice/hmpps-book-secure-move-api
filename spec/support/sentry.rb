RSpec.shared_examples 'captures a message in Sentry' do
  before { allow(Sentry).to receive(:capture_message) }

  it 'captures a message in Sentry' do
    subject
    expect(Sentry).to have_received(:capture_message).with(sentry_message, sentry_options)
  end
end

RSpec.shared_examples 'captures an exception in Sentry' do
  before { allow(Sentry).to receive(:capture_exception) }

  it 'captures an exception in Sentry' do
    subject
    expect(Sentry).to have_received(:capture_exception).with(instance_of(sentry_exception), sentry_options)
  end
end
