# frozen_string_literal: true

module AddressData
  @@data = nil

  def self.read_data_files
    @@data = []
    Dir['data/*.json'].each { |filename| @@data << JSON.parse(File.read(filename)) }
  end

  def self.get_data_files
    read_data_files if @@data.nil?
    @@data
  end

  def self.find_addresses(name)
    get_data_files.find { |f| f['name'] == name }['addresses']
  end
end
