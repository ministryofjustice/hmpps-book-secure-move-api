class ResponseAudit < ApplicationRecord
  belongs_to :request_audit

  scope :person_reads, ->(person_id) do
    direct_query = { id: person_id, type: 'people' }.to_json
    relationship_query = { relationships: { person: { data: { id: person_id, type: 'people' } } } }.to_json
    where('response @> ?', direct_query).or(where('response @> ?', relationship_query))
  end
end
