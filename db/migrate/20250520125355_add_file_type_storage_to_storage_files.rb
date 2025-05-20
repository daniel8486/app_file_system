class AddFileTypeStorageToStorageFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :storage_files, :file_type_storage, :integer
  end
end
