class TimeSince
  def initialize(start = Time.zone.now)
    @start = start
  end

  def get(time = Time.zone.now)
    (time - @start).seconds
  end

  def reset
    @start = Time.zone.now
  end
end
