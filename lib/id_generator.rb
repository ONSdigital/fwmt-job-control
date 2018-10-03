class IDGenerator
  def initialize(kind, id_single=nil, id_list=nil, id_incr_start=nil)
    raise ArgumentError "invalid kind" if not [:single, :list, :incr, :rand].include?(kind)
    @kind = kind
    @last_id = 0
    case @kind
    when :single
      @last_id = id_single
    when :list
      raise ArgumentError "id list not set" if id_list == nil
      raise ArgumentError "id list not a list" if not id_list.is_a?(Array)
      @id_list = id_list
      @index = 0
    when :incr
      raise ArgumentError "id start point is not set" if id_incr_start == nil
      raise ArgumentError "id start point is not a string" if not id_incr_start.is_a?(String)
      raise ArgumentError "id start point is not a numeric string" if (not Integer(id_incr_start) rescue true)
      @last_id = id_incr_start
    when :rand
    end
  end

  def generate
    case @kind
    when :single
      id = @last_id
    when :list
      id = @id_list[@index]
      @index += 1
    when :incr
      id = (@last_id.to_i + 1).to_s
    when :rand
      id = SecureRandom.hex(4)
    end
    @last_id = id
    return id
  end
end
