require 'fileutils'
require 'yaml/store'

# Storage saves data on filestystem
class Storage
  def initialize(location_path = ENV['LOCATION_PATH'])
    @location_path = location_path
  end

  def create_folder(prefix, file_path)
    dirname = "#{@location_path}/#{prefix}/#{file_path}"
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  end

  def store_data(prefix, file_path, data)
    dirname = "#{@location_path}/#{prefix}"
    store = YAML::Store.new("#{dirname}/#{file_path}.yml")
    store.transaction do
      data.each do |key, value|
        store[key] = value
      end
    end
  end
end
