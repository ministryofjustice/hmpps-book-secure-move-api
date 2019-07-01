# frozen_string_literal: true

class IdentifierType < ApplicationRecord
  validates :key, presence: true
  validates :title, presence: true

  alias key id
end
