require 'rails_helper'

RSpec.describe "StorageFiles", type: :request do
  let!(:directory) { Directory.create!(name: "Pasta Teste") }
  let!(:storage_file) { StorageFile.create!(name: "arquivo.txt", directory: directory, file_type_storage: :disk) }

  describe "GET /directories/:directory_id/storage_files" do
    it "retorna http success" do
      get directory_storage_files_path(directory), as: :html
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /directories/:directory_id/storage_files/:id" do
    it "retorna http success" do
      get directory_storage_file_path(directory, storage_file), as: :html
      expect(response).to have_http_status(:success)
    end
  end
end
