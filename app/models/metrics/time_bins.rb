module Metrics
  module TimeBins
    TimeBin = Struct.new(:title, :date_from_offset, :date_to_offset)

    COMMON_TIME_BINS = [
      TimeBin.new('the past inc today', nil, 0),
      TimeBin.new('past 30 days inc today', -29, 0),
      TimeBin.new('past 7 days inc today', -6, 0),
      TimeBin.new('yesterday', -1, -1),
      TimeBin.new('today', 0, 0),
      TimeBin.new('tomorrow', 1, 1),
      TimeBin.new('next 7 days exc today', 1, 7),
      TimeBin.new('next 30 days exc today', 1, 30),
      TimeBin.new('the future exc today', 1, nil),
    ].freeze

    def apply_time_bin(obj, time_bin)
      if time_bin.date_from_offset.present? && time_bin.date_to_offset.present? && time_bin.date_from_offset == time_bin.date_to_offset
        obj = obj.where(date: Time.zone.now + time_bin.date_from_offset.days)
      else
        obj = obj.where('date >= ?', Time.zone.today + time_bin.date_from_offset.days) if time_bin.date_from_offset.present?
        obj = obj.where('date <= ?', Time.zone.today + time_bin.date_to_offset.days) if time_bin.date_to_offset.present?
      end
      obj
    end
  end
end
