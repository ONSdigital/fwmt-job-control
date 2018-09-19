module AddressData
  @@data = nil

  def self.read_data_files
    @@data = []
    for filename in Dir["data/*.json"]
      @@data << JSON.parse(File.read(filename))
    end
    p @@data
  end

  def self.get_data_files
    if @@data == nil
      @@data = read_data_files
    end

    return @@data
  end
end
