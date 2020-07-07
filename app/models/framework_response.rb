# frozen_string_literal: true

class FrameworkResponse < VersionedModel
  validates :type, presence: true

  belongs_to :framework_question
  belongs_to :person_escort_record
  has_many :dependents, class_name: 'FrameworkResponse',
                        foreign_key: 'parent_id'

  belongs_to :parent, class_name: 'FrameworkResponse', optional: true

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
