class DateGenerator
  def initialize(kind, hours=nil, days=nil)
    raise ArgumentError "invalid kind" if not [:single, :list].include?(kind)
    @kind = kind
    case @kind
    when :set
      @authnos = [authno_single]
    when :hours
      raise ArgumentError "no hours provided" if hours == nil
      @hours = hours
    when :days
      raise ArgumentError "no days provided" if days == nil
      @days = days
    end
  end

  def date_now
    return Time.now.utc.iso8601
  end

  def date_now_plus_hours(hours)
    return (Time.now + (60 * 60 * hours)).utc.iso8601
  end

  def date_now_plus_days(days)
    return (Time.now + (60 * 60 * 24 * days)).utc.iso8601
  end

  def generate
    case @kind
    when :set
      return date_now
    when :hours
      return date_now_plus_hours @hours
    when :days
      return date_now_plus_days @days
    end
  end
end
