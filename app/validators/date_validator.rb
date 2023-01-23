# frozen_string_literal: true

class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if record.public_send("#{attribute}_before_type_cast").blank?

    unless value.acts_like?(:date)
      record.errors.add(attribute, :invalid)
    end
  end
end
