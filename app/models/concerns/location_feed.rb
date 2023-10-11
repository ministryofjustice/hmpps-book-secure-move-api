module LocationFeed
  def for_feed
    super.tap do |common_feed_attributes|
      location_key = self.class::LOCATION_ATTRIBUTE_KEY.to_s
      location_method = location_key.sub('_id', '')
      prefix = location_key == 'location_id' ? nil : location_key.sub('_location_id', '')

      updated_location = public_send(location_method)&.for_feed(prefix:) || { location_method => nil }

      common_feed_attributes['details'].merge!(updated_location)
      common_feed_attributes['details'].delete(location_key)
    end
  end
end
