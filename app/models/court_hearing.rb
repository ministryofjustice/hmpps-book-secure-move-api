class CourtHearing < ApplicationRecord
  belongs_to :move, optional: true

  validates_presence_of :start_time
end
