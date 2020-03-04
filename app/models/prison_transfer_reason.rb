# frozen_string_literal: true

class PrisonTransferReason < ApplicationRecord
  has_many :moves, dependent: :nullify

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true

  scope :ordered_by_title, ->(direction) { order('prison_transfer_reasons.title' => direction) }
end
