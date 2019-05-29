class Profile::ProfileAttribute
  attr_accessor :description, :comments, :profile_attribute_type_id
  attr_reader :date, :expiry_date

  def initialize(attributes = {})
    attributes.symbolize_keys!

    self.description = attributes[:description]
    self.comments = attributes[:comments]
    self.date = attributes[:date]
    self.expiry_date = attributes[:expiry_date]
    self.profile_attribute_type_id = attributes[:profile_attribute_type_id]
  end

  def date=(value)
    @date = value.is_a?(String) ? Date.parse(value) : value
  end

  def expiry_date=(value)
    @expiry_date = value.is_a?(String) ? Date.parse(value) : value
  end

  def empty?
    description.blank?
  end

  def as_json
    {
      description: description,
      comments: comments,
      date: date,
      expiry_date: expiry_date,
      profile_attribute_type_id: profile_attribute_type_id
    }
  end
end
