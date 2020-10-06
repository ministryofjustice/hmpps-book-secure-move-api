# frozen_string_literal: true

class SubscriptionSerializer
  include JSONAPI::Serializer

  set_type :subscriptions

  attributes :callback_url, :enabled

  # NB: take care not to expose :username, :password or :secret in the serializer
end
