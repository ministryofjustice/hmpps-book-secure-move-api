# frozen_string_literal: true

class Profile
  class ProfileAttribute < ActiveModelSerializers::Model
    attributes(
      :description,
      :comments,
      :profile_attribute_type_id,
      :date,
      :expiry_date,
      :category,
      :user_type
    )

    attr_accessor :description, :comments, :profile_attribute_type_id, :category, :user_type
    attr_reader :date, :expiry_date

    def initialize(attributes = {})
      attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)

      self.description = attributes[:description]
      self.comments = attributes[:comments]
      self.date = attributes[:date]
      self.expiry_date = attributes[:expiry_date]
      self.profile_attribute_type_id = attributes[:profile_attribute_type_id]
      self.category = attributes[:category]
      self.user_type = attributes[:user_type]
      super
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
        profile_attribute_type_id: profile_attribute_type_id,
        category: category,
        user_type: user_type
      }
    end

    def risk_alert?
      category == 'risk'
    end

    def health_alert?
      category == 'health'
    end

    def court_information?
      category == 'court_information'
    end

    def set_category_and_user_type
      return unless profile_attribute_type_id.present? && category.blank?

      profile_attribute_type = ProfileAttributeType.find(profile_attribute_type_id)
      self.category = profile_attribute_type.category
      self.user_type = profile_attribute_type.user_type
    end
  end
end
