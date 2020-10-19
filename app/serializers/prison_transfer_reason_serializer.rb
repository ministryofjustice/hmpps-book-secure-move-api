# frozen_string_literal: true

class PrisonTransferReasonSerializer
  include JSONAPI::Serializer

  INCLUDED_ATTRIBUTES = %i[title key disabled_at].freeze

  set_type :prison_transfer_reasons

  attributes(*INCLUDED_ATTRIBUTES)
end
