module Metrics
  module TimeBins
    TimeBin = Struct.new(:title, :date_from_offset, :date_to_offset)

    COMMON_TIME_BINS = [
      TimeBin.new('the past', nil, 0),
      TimeBin.new('past 30 days', -29, 0),
      TimeBin.new('past 7 days', -6, 0), # includes today
      TimeBin.new('yesterday', -1, -1),
      TimeBin.new('today', 0, 0),
      TimeBin.new('tomorrow', 1, 1),
      TimeBin.new('next 7 days', 0, 6), # includes today
      TimeBin.new('next 30 days', 0, 30),
      TimeBin.new('the future', 0, nil),
    ].freeze
  end
end
