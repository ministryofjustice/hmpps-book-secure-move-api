# frozen_string_literal: true

class Framework < ApplicationRecord
  validates :name, presence: true
  validates :version, presence: true

  has_many :framework_questions
end
