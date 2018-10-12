# frozen_string_literal: true

class DateGenerator
  def initialize(kind, date = nil, hours = nil, days = nil)
    raise ArgumentError, 'invalid kind' unless %w[set hours days].include?(kind)

    case kind
    when 'set'
      @kind = :set
      raise ArgumentError, 'no date provided' if date.nil?

      @date = date_parsed(date)
    when 'hours'
      @kind = :hours
      raise ArgumentError, 'no hours provided' if hours.nil?

      @date = date_now_plus_hours(hours)
    when 'days'
      @kind = :days
      raise ArgumentError, 'no days provided' if days.nil?

      @date = date_now_plus_days(days)
    end
  end

  def date_parsed(date)
    Time.httpdate(date)
  rescue ArgumentError
    Time.parse(date)
  end

  def date_now
    Time.now.utc.iso8601
  end

  def date_now_plus_hours(hours)
    (Time.now + (60 * 60 * hours.to_i)).utc.iso8601
  end

  def date_now_plus_days(days)
    (Time.now + (60 * 60 * 24 * days.to_i)).utc.iso8601
  end

  def generate
    @date
  end
end
