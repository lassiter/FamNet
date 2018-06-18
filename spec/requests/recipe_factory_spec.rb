require 'rails_helper'

RSpec.describe "RecipeFactoryController", type: :request do
  describe "GET /recipe_factories" do
    it "works! (now write some real specs)" do
      get recipe_factories_path
      expect(response).to have_http_status(200)
    end
  end
end
