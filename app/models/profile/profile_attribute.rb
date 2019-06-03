# frozen_string_literal: true

class Profile
  class ProfileAttribute < ActiveModelSerializers::Model
    attributes :description, :comments, :profile_attribute_type_id, :date, :expiry_date

    attr_accessor :description, :comments, :profile_attribute_type_id
    attr_reader :date, :expiry_date

    def initialize(attributes = {})
      attributes.symbolize_keys!

      self.description = attributes[:description]
      self.comments = attributes[:comments]
      self.date = attributes[:date]
      self.expiry_date = attributes[:expiry_date]
      self.profile_attribute_type_id = attributes[:profile_attribute_type_id]
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
        profile_attribute_type_id: profile_attribute_type_id
      }
    end

    def risk_alert?
      # TODO: Cache profile attribute types
      ProfileAttributeType.find(profile_attribute_type_id)&.category == 'risk'
    end

    def health_alert?
      # TODO: Cache profile attribute types
      ProfileAttributeType.find(profile_attribute_type_id)&.category == 'health'
    end

    def court_information?
      # TODO: Cache profile attribute types
      ProfileAttributeType.find(profile_attribute_type_id)&.category == 'court_information'
    end
  end
end
