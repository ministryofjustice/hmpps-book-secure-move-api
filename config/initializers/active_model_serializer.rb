ActiveModel::Serializer.config.adapter = ActiveModelSerializers::Adapter::JsonApi
ActiveModel::Serializer.config.key_transform = :underscore
ActiveSupport::JSON::Encoding.time_precision = 0
