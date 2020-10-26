require 'rails_helper'

RSpec.describe IncludeParamHandler do
  subject(:service) { described_class.new(params) }

  let(:params) { HashWithIndifferentAccess.new(include: include) }

  describe 'included_relationships' do
    subject { service.included_relationships }

    context 'when the include param is nil' do
      let(:include) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the include param is a splittable string' do
      let(:include) { 'foo.bar,baz.qux' }

      it { is_expected.to eq(['foo.bar', 'baz.qux']) }
    end

    context 'when the include param is an empty string' do
      let(:include) { '' }

      it { is_expected.to eq([]) }
    end
  end

  describe 'active_record_relationships' do
    subject { service.active_record_relationships }

    context 'when the include param is nil' do
      let(:include) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the include param is a splittable string' do
      let(:include) { 'foo.bar,bla,baz.qux.qax' }

      it { is_expected.to eq([{ foo: :bar }, :bla, { baz: { qux: :qax } }]) }
    end

    context 'when the include param needs aliasing' do
      let(:include) { 'foo.flags,bar.bla.questions,responses,timeline_events' }

      it { is_expected.to eq([{ foo: :framework_flags }, { bar: { bla: :framework_questions } }, :framework_responses, :events]) }
    end

    context 'when the include param is an empty string' do
      let(:include) { '' }

      it { is_expected.to be_nil }
    end
  end
end
