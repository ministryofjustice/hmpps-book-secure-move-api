# frozen_string_literal: true

class Gender < ApplicationRecord
  validates :title, presence: true
  validates :key, presence: true


  def for_feed()
    {
        "gender" => key,
    }
  end

end
