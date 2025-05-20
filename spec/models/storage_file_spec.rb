require "rails_helper"

RSpec.describe StorageFilePathService do
  subject(:path_builder) { described_class.new(storage_file, separator: separator) }

  let(:separator) { "/" }

  describe "#call" do
    context "com storage_file e directory via FactoryBot" do
      let(:directory) { create(:directory, name: "docs") }
      let(:storage_file) { create(:storage_file, name: "file.txt", directory: directory) }

      it "retorna o caminho completo" do
        expect(path_builder.call).to eq("docs/file.txt")
      end
    end

    context "com doubles válidos" do
      let(:directory) { instance_double("Directory", dir_path: "docs") }
      let(:storage_file) { instance_double("StorageFile", name: "file.txt", directory: directory) }

      it "retorna caminho construído corretamente" do
        expect(path_builder.call).to eq("docs/file.txt")
      end
    end

    context "arquivo sem diretório (usando double)" do
      let(:storage_file) { instance_double("StorageFile", name: "file.txt", directory: nil) }

      it "retorna apenas o nome do arquivo" do
        expect(path_builder.call).to eq("file.txt")
      end
    end

    context "arquivo é nil" do
      let(:storage_file) { nil }

      it "retorna string vazia" do
        expect(path_builder.call).to eq("")
      end
    end

    context "arquivo sem nome (usando double)" do
      let(:storage_file) { instance_double("StorageFile", name: nil, directory: nil) }

      it "retorna string vazia" do
        expect(path_builder.call).to eq("")
      end
    end

    context "com separador customizado '-'" do
      let(:separator) { "-" }
      let(:directory) { instance_double("Directory", dir_path: "docs") }
      let(:storage_file) { instance_double("StorageFile", name: "file.txt", directory: directory) }

      it "usa o separador corretamente" do
        expect(path_builder.call).to eq("docs-file.txt")
      end
    end

    context "objeto que não responde a name" do
      let(:storage_file) { Object.new }

      it "retorna string vazia" do
        expect(path_builder.call).to eq("")
      end
    end

    context "diretório sem método dir_path" do
      let(:directory) { double("Directory") }
      let(:storage_file) { double("StorageFile", name: "file.txt", directory: directory) }

      it "retorna só o nome do arquivo" do
        expect(path_builder.call).to eq("file.txt")
      end
    end

    context "objeto responde false a respond_to?(:name)" do
      let(:directory) { double("Directory", dir_path: "docs") }
      let(:storage_file) do
        obj = double("StorageFile", name: "file.txt", directory: directory)
        allow(obj).to receive(:respond_to?).with(:name).and_return(false)
        obj
      end

      it "retorna string vazia" do
        expect(path_builder.call).to eq("")
      end
    end
  end
end
