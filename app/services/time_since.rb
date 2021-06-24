class TimeSince
  def initialize(start = Time.zone.now)
    @start = start
  end

  def get
    (Time.zone.now - @start).seconds
  end

  def reset
    @start = Time.zone.now
  end
end
