require 'rails_helper'

RSpec.describe IncludeParamHandler do
  subject(:service) { described_class.new(params) }

  let(:params) { HashWithIndifferentAccess.new(include: include, meta: meta) }
  let(:include) { nil }
  let(:meta) { nil }

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

  describe 'meta_fields' do
    subject { service.meta_fields }

    context 'when the meta param is nil' do
      let(:meta) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the meta param is a splittable string' do
      let(:meta) { 'foo,bar,baz' }

      it { is_expected.to contain_exactly('foo', 'bar', 'baz') }
    end

    context 'when the meta param is an empty string' do
      let(:meta) { '' }

      it { is_expected.to eq([]) }
    end
  end

  describe 'active_record_relationships' do
    subject { service.active_record_relationships }

    context 'when the include and meta param are nil' do
      let(:include) { nil }
      let(:meta) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the meta and include param are both a splittable string' do
      let(:include) { 'foo.bar,baz.qux.qax' }
      let(:meta) { 'bla' }

      it { is_expected.to contain_exactly({ foo: :bar }, :bla, { baz: { qux: :qax } }) }
    end

    context 'when the include and meta param need aliasing' do
      let(:include) { 'foo.flags,bar.bla.questions,responses,timeline_events' }
      let(:meta) { 'vehicle_registration' }

      it { is_expected.to contain_exactly({ foo: :framework_flags }, { bar: { bla: :framework_questions } }, :framework_responses, :generic_events, :journeys) }
    end

    context 'when the include param needs expanding to include multiple relationships' do
      let(:include) { 'foo,important_events' }

      it { is_expected.to eq([:foo, { incident_events: {}, profile: { person_escort_record: :medical_events } }]) }
    end

    context 'when the meta param is set without the include param' do
      let(:meta) { 'foo,vehicle_registration' }

      it { is_expected.to contain_exactly(:foo, :journeys) }
    end

    context 'when the include param is an empty string' do
      let(:include) { '' }

      it { is_expected.to be_nil }
    end

    context 'when the meta param is an empty string' do
      let(:meta) { '' }

      it { is_expected.to be_nil }
    end
  end
end
