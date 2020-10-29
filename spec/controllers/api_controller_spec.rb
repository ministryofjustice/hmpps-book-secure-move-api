# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ApiController do
  describe '.user_for_paper_trail' do
    let(:headers) { {} }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      allow(controller).to receive(:headers).and_return(headers)
    end

    context 'when the current_user does not have an owner (frontend)' do
      let(:current_user) { Doorkeeper::Application.create(name: 'test') }

      context 'when the X-Current-User header is present' do
        let(:headers) { { 'X-Current-User' => 'TEST_USER' } }

        it 'returns the value of the X-Current-User header' do
          expect(controller.user_for_paper_trail).to eq('TEST_USER')
        end
      end

      context 'when the X-Current-User header is not present' do
        it 'returns nil' do
          expect(controller.user_for_paper_trail).to eq(nil)
        end
      end
    end

    context 'when the current_user does have an owner (supplier)' do
      let(:owner_supplier) { create :supplier }
      let(:current_user) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

      context 'when the X-Current-User header is present' do
        let(:headers) { { 'X-Current-User' => 'TEST_USER' } }

        it 'returns the value of the X-Current-User header' do
          expect(controller.user_for_paper_trail).to eq('TEST_USER')
        end
      end

      context 'when the X-Current-User header is not present' do
        it "returns the supplier's id" do
          expect(controller.user_for_paper_trail).to eq(owner_supplier.id)
        end
      end
    end
  end

  describe '.info_for_paper_trail' do
    let(:headers) { {} }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      allow(controller).to receive(:headers).and_return(headers)
    end

    context 'when the current_user does not have an owner (frontend)' do
      let(:current_user) { Doorkeeper::Application.create(name: 'test') }

      context 'when the X-Current-User header is present' do
        let(:headers) { { 'X-Current-User' => 'TEST_USER' } }

        it "returns 'user'" do
          expect(controller.info_for_paper_trail[:user_type]).to eq('user')
        end
      end

      context 'when the X-Current-User header is not present' do
        it "returns 'supplier'" do
          expect(controller.info_for_paper_trail[:user_type]).to eq('supplier')
        end
      end
    end

    context 'when the current_user does have an owner (supplier)' do
      let(:owner_supplier) { create :supplier }
      let(:current_user) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

      context 'when the X-Current-User header is present' do
        let(:headers) { { 'X-Current-User' => 'TEST_USER' } }

        it "returns 'user'" do
          expect(controller.info_for_paper_trail[:user_type]).to eq('user')
        end
      end

      context 'when the X-Current-User header is not present' do
        it "returns 'supplier'" do
          expect(controller.info_for_paper_trail[:user_type]).to eq('supplier')
        end
      end
    end
  end
end
