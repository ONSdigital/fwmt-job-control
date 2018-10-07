class AddressGenerator

  def initialize(kind, strategy, addr_single=nil, addr_preset=nil, addr_list=nil, addr_file=nil)
    raise ArgumentError "invalid kind" if not [:single, :preset, :list].include?(kind)
    @kind = kind
    raise ArgumentError "invalid strategy" if not [:random, :incremental, :once_per].include?(strategy)
    @strategy = strategy
    case @kind
    when :single
      raise ArgumentError "no address provided" if addr_single == nil
      raise ArgumentError "address is not a hash" if not addr_single.is_a?(Hash)
      @addresses = [addr_single]
    when :preset
      raise ArgumentError "no address preset list provided" if addr_single == nil
      @addresses = AddressData.get_data_files(addr_preset)
    when :list
      raise ArgumentError "no address list provided" if addr_single == nil
      raise ArgumentError "address list is not an array" if not addr_preset.is_a?(Array)
      raise ArgumentError "address list contains non-hashes" if addr_preset.all? { |addr| addr.is_a?(Hash) }
      @addresses = addr_list
    when :file
      raise ArgumentError "no address file provided" if addr_file == nil
      @addresses = []
      CSV.parse(addr_file) do |row|
        @addresses << {
          "line1" => row[0],
          "line2" => row[1],
          "line3" => row[2],
          "line4" => row[3],
          "townName" => row[4],
          "postcode" => row[5],
          "latitude" => row[5],
          "longitude" => row[6],
        }
      end
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
    return {
      line1: addr['line1'],
      line2: addr['line2'],
      line3: addr['line3'],
      line4: addr['line4'],
      townName: addr['townName'],
      postCode: addr['postcode'],
      latitude: addr['latitude'],
      longitude: addr['longitude'],
    }
  end
end
