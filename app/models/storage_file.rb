class StorageFile < ApplicationRecord
  belongs_to :directory
  has_one_attached :file

  enum :file_type_storage, { blob: 0, s3: 1, disk: 2 }, default: :disk
  validates :name, presence: true, uniqueness: { scope: :directory_id }

  def content_type
    return blob_data if blob?
    return file.download if file.attached?

    nil
  end

  def file_path
    StorageFilePathService.new(self).call
  end
end
