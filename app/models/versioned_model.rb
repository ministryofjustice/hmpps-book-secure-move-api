# frozen_string_literal: true

class VersionedModel < ApplicationRecord
  self.abstract_class = true

  has_paper_trail
end
