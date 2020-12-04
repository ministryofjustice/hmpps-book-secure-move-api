# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SerializerVersionChooser do
  subject(:chooser) { described_class.call(interpolatable) }

  context 'when a version 2 serializer exists' do
    let(:interpolatable) { Move }

    it { is_expected.to eq(V2::MoveSerializer) }
  end

  context 'when an unversioned serializer exists' do
    let(:interpolatable) { Location }

    it { is_expected.to eq(LocationSerializer) }
  end

  context 'when the interpolatable is in snake case and plural form' do
    let(:interpolatable) { :moves }

    it { is_expected.to eq(V2::MoveSerializer) }
  end

  context 'when the serializer does not exist' do
    let(:interpolatable) { Notifier }

    it { expect { chooser }.to raise_error(NameError, /uninitialized constant NotifierSerializer/) }
  end
end
