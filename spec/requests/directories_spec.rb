require "rails_helper"

RSpec.describe "Directories", type: :request do
  describe "GET /index" do
    it "retorna http success" do
      get directories_path
      expect(response).to have_http_status(:success)
    end
  end
end
