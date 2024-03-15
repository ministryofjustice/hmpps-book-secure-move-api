module LocationFeed
  def for_feed
    super.tap do |common_feed_attributes|
      location_keys = self.class.const_defined?('LOCATION_ATTRIBUTE_KEYS') && self.class::LOCATION_ATTRIBUTE_KEYS&.map(&:to_s)
      location_keys = [self.class::LOCATION_ATTRIBUTE_KEY.to_s] if location_keys.blank?

      location_keys.each { |location_key| add_location(common_feed_attributes, location_key) }
    end
  end

private

  def add_location(common_feed_attributes, location_key)
    location_method = location_key.sub('_id', '')
    prefix = location_key == 'location_id' ? nil : location_key.sub('_location_id', '')

    updated_location = public_send(location_method)&.for_feed(prefix:) || { location_method => nil }

    common_feed_attributes['details'].merge!(updated_location)
    common_feed_attributes['details'].delete(location_key)
  end
end
