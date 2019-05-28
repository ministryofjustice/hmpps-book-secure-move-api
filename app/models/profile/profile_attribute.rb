class Profile::ProfileAttribute
  attr_reader :description, :comments, :date, :expiry_date, :profile_attribute_type_id

  def initialize(attributes = {})
    attributes.symbolize_keys!

    self.description = attributes[:description]
    self.comments = attributes[:comments]
    self.date = attributes[:date]
    self.expiry_date = attributes[:expiry_date]
    self.profile_attribute_type_id = attributes[:profile_attribute_type_id]
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
