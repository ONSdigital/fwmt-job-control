# frozen_string_literal: true

class AddressGenerator
  def initialize(kind, strategy, addr_single = nil, addr_preset = nil, addr_list = nil, addr_file = nil)
    raise ArgumentError, 'invalid kind' unless %w[single preset list file].include?(kind)
    raise ArgumentError, 'invalid strategy' unless %w[random incremental once_per].include?(strategy)

    case strategy
    when 'random'
      @strategy = :random
    when 'incremental'
      @strategy = :incremental
    when 'once_per'
      @strategy = :once_per
    end
    case kind
    when 'single'
      @kind = :single
      raise ArgumentError, 'no address provided' if addr_single.nil?
      raise ArgumentError, 'address is not a string' unless addr_single.is_a?(String)

      @addresses = [parse_line(addr_single.split(','))]
    when 'preset'
      @kind = :preset
      raise ArgumentError, 'no address preset list provided' if addr_single.nil?

      @addresses = AddressData.find_addresses(addr_preset)
    when 'list'
      @kind = :list
      raise ArgumentError, 'no address list provided' if addr_single.nil?
      raise ArgumentError, 'address list is not an array' unless addr_preset.is_a?(Array)
      raise ArgumentError, 'address list contains non-hashes' if addr_preset.all? { |addr| addr.is_a?(Hash) }

      @addresses = addr_list
    when 'file'
      @kind = :file
      raise ArgumentError, 'no address file provided' if addr_file.nil?

      p addr_file
      while data = addr_file[:tempfile].read(65536)
        @addresses = []
        CSV.parse(data) do |row|
          @addresses << parse_line(row)
        end
      end
    end
    @index = 0
  end

  def parse_line(row)
    {
      'line1' => row[0],
      'line2' => row[1],
      'line3' => row[2],
      'line4' => row[3],
      'townName' => row[4],
      'postcode' => row[5],
      'latitude' => row[5],
      'longitude' => row[6]
    }
  end

  def length
    @addresses.length
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
    {
      line1: addr['line1'],
      line2: addr['line2'],
      line3: addr['line3'],
      line4: addr['line4'],
      townName: addr['townName'],
      postCode: addr['postcode'],
      latitude: addr['latitude'],
      longitude: addr['longitude']
    }
  end
end
