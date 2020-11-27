# frozen_string_literal: true

class VersionedModel < ApplicationRecord
  self.abstract_class = true

  has_paper_trail ignore: [:updated_at]
end
