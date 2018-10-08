class ResnoGenerator
  def initialize(kind, authno_single=nil, authno_list=nil)
    raise ArgumentError "invalid kind" if not [:single, :list].include?(kind)
    @kind = kind
    case @kind
    when :single
      raise ArgumentError "no authno provided" if authno_single == nil
      @authnos = [authno_single]
    when :list
      raise ArgumentError "no authno list provided" if authno_list == nil
      raise ArgumentError "authno list is not an string" if not authno_list.is_a?(String)
      @authnos = authno_list.split(',')
    end
  end

  def length
    return @authnos.length
  end

  def generate
    return @authnos.sample
  end
end
