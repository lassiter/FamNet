require 'rails_helper'

RSpec.describe "CommentReplies", type: :request do
  describe "GET /comment_replies" do
    it "works! (now write some real specs)" do
      get comment_replies_path
      expect(response).to have_http_status(200)
    end
  end
end
