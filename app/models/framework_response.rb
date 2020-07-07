# frozen_string_literal: true

class FrameworkResponse < VersionedModel
  validates :type, presence: true

  belongs_to :framework_question
  belongs_to :person_escort_record
  has_many :dependents, class_name: 'FrameworkResponse',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkResponse', optional: true
  validates_each :value, on: :update do |record, _attr, value|
    if value.blank? && record.parent&.option_selected?(record.framework_question.dependent_value) && record.framework_question.required
      record.errors.add(:value, :blank)
    end
  end

  def self.find_sti_class(type_name)
    case type_name
    when 'object'
      type_name = 'FrameworkResponse::Object'
    when 'string'
      type_name = 'FrameworkResponse::String'
    when 'array'
      type_name = 'FrameworkResponse::Array'
    when 'collection'
      type_name = 'FrameworkResponse::Collection'
    end

    super
  end
end
