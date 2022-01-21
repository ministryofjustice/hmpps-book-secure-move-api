class PrisonNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    if value.include?(':')
      record.errors.add(attribute, options[:message] || 'is not a valid prison number')
    end
  end
end
