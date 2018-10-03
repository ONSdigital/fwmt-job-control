class AddressGenerator

  def initialize(kind, strategy, addr_single=nil, addr_preset=nil, addr_list=nil)
    raise ArgumentError "invalid kind" if not [:single, :preset, :list].include?(kind)
    @kind = kind
    raise ArgumentError "invalid strategy" if not [:random, :incremental, :once_per].include?(strategy)
    @strategy = strategy
    case @kind
    when :single
      raise ArgumentError "no address provided" if addr_single == null
      raise ArgumentError "address is not a hash" if not addr_single.is_a?(Hash)
      @addresses = [addr_single]
    when :preset
      raise ArgumentError "no address preset list provided" if addr_single == null
      @addresses = AddressData.get_data_files(addr_preset)
    when :list
      raise ArgumentError "no address list provided" if addr_single == null
      raise ArgumentError "address list is not an array" if not addr_preset.is_a?(Array)
      raise ArgumentError "address list contains non-hashes" if addr_preset.all? { |addr| addr.is_a?(Hash) }
      @addresses = addr_list
    end
    @index = 0
  end

  def length
    return @addresses.length
  end

  def generate
    case @strategy
    when :random
      addr = @addresses.sample
    when :incremental
      addr = @addresses[@index % length]
    when :once_per
      addr = @addresses[@index % length]
    end
    @index += 1
    return addr
  end
end
