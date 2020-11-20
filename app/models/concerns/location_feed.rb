module LocationFeed
  def for_feed
    super.tap do |common_feed_attributes|
      location_key = self.class::LOCATION_ATTRIBUTE_KEY.to_s
      location_method = location_key.sub('_id', '')
      prefix = location_key == 'location_id' ? nil : location_key.sub('_location_id', '')

      feed_details = common_feed_attributes['details']
        .deep_dup
        .except(location_key)
      feed_details.merge!(public_send(location_method).for_feed(prefix: prefix))

      common_feed_attributes['details'] = feed_details
    end
  end
end
