class CourtHearing < ApplicationRecord
  belongs_to :move, optional: true

  validates :start_time, presence: true
  validates :comments, length: { maximum: 240 }
end
