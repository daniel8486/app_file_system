class StorageFile < ApplicationRecord
  belongs_to :directory
  has_one_attached :file

  enum :file_type_storage, { blob: 0, s3: 1, disk: 2 }, default: :disk

  validates :name, presence: true, uniqueness: { scope: :directory_id }


  def file_content_type
    file.blob&.content_type if file.attached?
  end


  def storage_type
    file_type_storage.to_sym
  end


  def human_readable_type
    return nil unless file_content_type

    case file_content_type
    when /image/
      "Imagem"
    when /pdf/
      "Documento PDF"
    when /zip/
      "Arquivo Compactado"
    when /json/
      "JSON"
    when /csv/
      "Planilha CSV"
    when /text/
      "Texto"
    else
      "Arquivo"
    end
  end

  def file_path
    StorageFilePathService.new(self).call
  end
end
