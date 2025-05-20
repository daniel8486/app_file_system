require 'rails_helper'

RSpec.describe StorageFile, type: :model do
  let(:directory) { create(:directory, name: "Dir Pai") }

  describe "associações" do
    it { should belong_to(:directory) }
    it { should have_one_attached(:file) }
  end

  describe "validações" do
    it { should validate_presence_of(:name) }

    it "não permite nomes duplicados no mesmo diretório" do
      create(:storage_file, name: "file.txt", directory: directory, file_type_storage: :disk)
      file2 = build(:storage_file, name: "file.txt", directory: directory, file_type_storage: :disk)
      expect(file2).not_to be_valid
    end

    it "permite nomes iguais em diretórios diferentes" do
      dir2 = create(:directory, name: "Outro Dir")
      create(:storage_file, name: "file.txt", directory: directory, file_type_storage: :disk)
      file2 = build(:storage_file, name: "file.txt", directory: dir2, file_type_storage: :disk)
      expect(file2).to be_valid
    end
  end

  describe "enum file_type_storage" do
    it "define os tipos corretamente" do
      file = build(:storage_file, file_type_storage: :disk)
      expect(file.disk?).to be true

      file.file_type_storage = :s3
      expect(file.s3?).to be true

      file.file_type_storage = :blob
      expect(file.blob?).to be true
    end
  end

  describe "#file_path" do
    it "chama o service e retorna o caminho" do
      file = build(:storage_file, name: "file.txt", directory: directory)
      expect(StorageFilePathService).to receive(:new).with(file).and_call_original
      file.file_path
    end

    it "retorna o caminho correto" do
      file = create(:storage_file, name: "file.txt", directory: directory)
      expect(file.file_path).to eq("Dir Pai/file.txt")
    end
  end

  describe "#content_type" do
    let(:file) { build(:storage_file, file_type_storage: :blob) }

    it "retorna blob_data se for blob" do
      allow(file).to receive(:blob?).and_return(true)
      allow(file).to receive(:blob_data).and_return("image/png")
      expect(file.content_type).to eq("image/png")
    end

    it "retorna file.download se file estiver attached" do
      allow(file).to receive(:blob?).and_return(false)
      fake_attachment = double("ActiveStorage::Attachment", attached?: true, download: "file-content")
      allow(file).to receive(:file).and_return(fake_attachment)

      expect(file.content_type).to eq("file-content")
    end

    it "retorna nil se não for blob e não tiver file" do
      allow(file).to receive(:blob?).and_return(false)
      fake_attachment = double("ActiveStorage::Attachment", attached?: false)
      allow(file).to receive(:file).and_return(fake_attachment)

      expect(file.content_type).to be_nil
    end
  end
end
