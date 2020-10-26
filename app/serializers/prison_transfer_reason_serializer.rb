# frozen_string_literal: true

class PrisonTransferReasonSerializer
  include JSONAPI::Serializer

  set_type :prison_transfer_reasons

  attributes :title, :key, :disabled_at
end
