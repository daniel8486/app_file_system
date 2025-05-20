class DirectoryPathService
 def initialize(directory)
    @directory = directory
 end

 def build
  return "" unless @directory
  path = []
  current_directory = @directory

  while current_directory
    path.unshift(current_directory.name)
    current_directory = current_directory.parent
  end
  path.join("/")
 end
end
