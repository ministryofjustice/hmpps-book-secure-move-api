# frozen_string_literal: true

RSpec.shared_examples 'an endpoint that paginates resources' do
  context 'with no pagination parameters' do
    it 'paginates 5 results per page' do
      expect(response_json['data'].size).to eq 5
    end

    it 'provides meta data with pagination' do
      expect(response_json['meta']['pagination']).to include_json(meta_pagination)
    end

    it 'provides pagination links' do
      expect(response_json['links']).to include_json(pagination_links)
    end
  end

  context 'with page parameter' do
    let(:params) { { page: 2 } }

    it 'returns 1 result on the second page' do
      expect(response_json['data'].size).to eq 1
    end
  end

  context 'with per_page parameter' do
    let(:params) { { per_page: 2 } }

    it 'allows setting a different page size' do
      expect(response_json['data'].size).to eq 2
    end
  end
end
