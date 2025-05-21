class StorageFilePathService
  DEFAULT_SEPARATOR = "/".freeze

  def initialize(storage_file, separator: DEFAULT_SEPARATOR)
    @storage_file = storage_file
    @separator = separator
  end

  def call
    return "" unless storage_file_valid?

    [ directory_path, file_name ].compact.join(@separator)
  end

  private

  attr_reader :storage_file

  def storage_file_valid?
    storage_file.respond_to?(:name) && storage_file.name.present?
  end

  def file_name
    storage_file.name
  end

  def directory_path
    directory = storage_file.respond_to?(:directory) ? storage_file.directory : nil
    path = directory&.respond_to?(:dir_path) ? directory.dir_path : nil
    path.to_s.strip.empty? ? nil : path
  end
end
