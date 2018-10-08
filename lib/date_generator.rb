class DateGenerator
  def initialize(kind, date=nil, hours=nil, days=nil)
    raise ArgumentError "invalid kind" if not [:single, :list].include?(kind)
    @kind = kind
    case @kind
    when :set
      raise ArgumentError "no date provided" if date == nil
      @date = date_parsed(date)
    when :hours
      raise ArgumentError "no hours provided" if hours == nil
      @date = date_now_plus_hours(hours)
    when :days
      raise ArgumentError "no days provided" if days == nil
      @date = date_now_plus_days(days)
    end
  end

  def date_parsed(date)
    return Time.httpdate(date) rescue Time.parse(date)
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
    return @date
  end
end
