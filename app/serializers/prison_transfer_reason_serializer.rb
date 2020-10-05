# frozen_string_literal: true

class PrisonTransferReasonSerializer
  include JSONAPI::Serializer

  set_type :prison_transfer_reasons

  attributes :id, :title, :key, :disabled_at
end
