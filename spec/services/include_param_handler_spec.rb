require 'rails_helper'

RSpec.describe IncludeParamHandler do
  subject(:service) { described_class.new(params) }

  let(:params) { HashWithIndifferentAccess.new(include: include) }

  context 'when the include param is nil' do
    let(:include) { nil }

    it { expect(service.call).to be_nil }
  end

  context 'when the include param is a splittable string' do
    let(:include) { 'foo.bar,baz.qux' }

    it { expect(service.call).to eq(['foo.bar', 'baz.qux']) }
  end
end
