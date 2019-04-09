# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'
end
