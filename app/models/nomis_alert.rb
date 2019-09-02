# frozen_string_literal: true

class NomisAlert < ApplicationRecord
  validates :type_code, presence: true
  validates :code, presence: true
  validates :type_description, presence: true
  validates :description, presence: true

  belongs_to :assessment_question, optional: true
end
