# frozen_string_literal: true

class PrisonTransferReason < ApplicationRecord
  has_many :moves, dependent: :nullify

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
end
