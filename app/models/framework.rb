# frozen_string_literal: true

class Framework < ApplicationRecord
  validates :name, presence: true
  validates :version, presence: true
  validates :name, uniqueness: { scope: :version }

  has_many :framework_questions
  has_many :person_escort_records

  scope :ordered_by_latest_version, -> { order(Arel.sql('cast(version as double precision) desc')) }
end
