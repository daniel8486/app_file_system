class CreateStorageFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :storage_files do |t|
      t.string :name
      t.references :directory, null: false, foreign_key: true
      t.integer :storage_type
      t.binary :blob_data

      t.timestamps
    end
  end
end
