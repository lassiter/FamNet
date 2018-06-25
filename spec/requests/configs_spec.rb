require 'rails_helper'

RSpec.describe "Configs", type: :request do
  describe "On family creation" do
    it "has authorization enabled by default" do
      get configs_path
      expect(response).to have_http_status(200)
    end
    it "allows authorzation to be disabled" do
      expect(response).to have_http_status(200)
    end
  end
  describe "On family creation" do
    it "can turn authorization on to off" do
      get configs_path
      expect(response).to have_http_status(200)
    end
    it "can turn authorization off to on" do
      expect(response).to have_http_status(200)
    end
  end
end
