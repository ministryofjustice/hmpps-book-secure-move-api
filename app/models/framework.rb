# frozen_string_literal: true

class Framework < ApplicationRecord
  validates :name, presence: true
  validates :version, presence: true
  validates :name, uniqueness: { scope: :version }

  has_many :framework_questions
end
