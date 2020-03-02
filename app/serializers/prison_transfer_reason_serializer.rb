# frozen_string_literal: true

class PrisonTransferReasonSerializer < ActiveModel::Serializer
  attributes :id, :title, :key, :disabled_at
end
