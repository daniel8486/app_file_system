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

  describe "#file_content_type" do
    let(:file) { build(:storage_file) }

    it "retorna o content_type do arquivo anexado" do
      fake_blob = double("ActiveStorage::Blob", content_type: "image/png")
      fake_attachment = double("ActiveStorage::Attachment", attached?: true, blob: fake_blob)
      allow(file).to receive(:file).and_return(fake_attachment)

      expect(file.file_content_type).to eq("image/png")
    end

    it "retorna nil se não houver arquivo anexado" do
      fake_attachment = double("ActiveStorage::Attachment", attached?: false)
      allow(file).to receive(:file).and_return(fake_attachment)

      expect(file.file_content_type).to be_nil
    end
  end

  describe "#human_readable_type" do
    let(:file) { build(:storage_file) }

    it "retorna 'Imagem' para tipos MIME que contenham 'image'" do
      allow(file).to receive(:file_content_type).and_return("image/jpeg")
      expect(file.human_readable_type).to eq("Imagem")
    end

    it "retorna 'Documento PDF' para tipos MIME que contenham 'pdf'" do
      allow(file).to receive(:file_content_type).and_return("application/pdf")
      expect(file.human_readable_type).to eq("Documento PDF")
    end

    it "retorna 'Arquivo Compactado' para tipos MIME que contenham 'zip'" do
      allow(file).to receive(:file_content_type).and_return("application/zip")
      expect(file.human_readable_type).to eq("Arquivo Compactado")
    end

    it "retorna 'JSON' para tipos MIME que contenham 'json'" do
      allow(file).to receive(:file_content_type).and_return("application/json")
      expect(file.human_readable_type).to eq("JSON")
    end

    it "retorna 'Planilha CSV' para tipos MIME que contenham 'csv'" do
      allow(file).to receive(:file_content_type).and_return("text/csv")
      expect(file.human_readable_type).to eq("Planilha CSV")
    end

    it "retorna 'Texto' para tipos MIME que contenham 'text'" do
      allow(file).to receive(:file_content_type).and_return("text/plain")
      expect(file.human_readable_type).to eq("Texto")
    end

    it "retorna 'Arquivo' para tipos MIME desconhecidos" do
      allow(file).to receive(:file_content_type).and_return("application/xyz")
      expect(file.human_readable_type).to eq("Arquivo")
    end

    it "retorna nil se não houver tipo MIME" do
      allow(file).to receive(:file_content_type).and_return(nil)
      expect(file.human_readable_type).to be_nil
    end
  end
end
