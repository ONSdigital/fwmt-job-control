module AddressData
  @@data = nil

  def self.read_data_files
    @@data = []
    for filename in Dir["data/*.json"]
      json = JSON.parse(File.read(filename))
      @@data << json
    end
  end

  def self.get_data_files
    if @@data == nil
      read_data_files
    end

    return @@data
  end
end
