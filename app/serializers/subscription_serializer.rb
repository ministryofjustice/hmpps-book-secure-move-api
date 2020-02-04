# frozen_string_literal: true

class SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :callback, :enabled

  # NB: take care not to expose :username, :password or :secret in the serializer
end
