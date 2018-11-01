# frozen_string_literal: true

class ResnoGenerator
  def initialize(kind, authno_single = nil, authno_list = nil)
    raise ArgumentError, 'invalid kind' unless %w[single list].include?(kind)

    case kind
    when 'single'
      @kind = :single
      raise ArgumentError, 'no authno provided' if authno_single.nil?

      @authnos = [authno_single]
    when 'list'
      @kind = :list
      raise ArgumentError, 'no authno list provided' if authno_list.nil?
      raise ArgumentError, 'authno list is not an string' unless authno_list.is_a?(String)

      @authnos = authno_list.split(',')
    end
  end

  def length
    @authnos.length
  end

  def generate
    @authnos.sample
  end
end
