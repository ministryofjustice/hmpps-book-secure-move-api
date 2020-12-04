# frozen_string_literal: true

class PrefillSourceSerializer
  include JSONAPI::Serializer

  attributes :confirmed_at, :created_at, :nomis_sync_status

  attribute :status do |object|
    object.status == 'unstarted' ? 'not_started' : object.status
  end
end
