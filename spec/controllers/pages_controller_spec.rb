require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'show' do
    it 'returns success' do
      get :show, params: { id: :overview }
      expect(response).to be_successful
    end
  end
end
