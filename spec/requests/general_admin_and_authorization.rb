require 'rails_helper'

RSpec.describe "Family Authorization and Administration", type: :request do
  describe 'Authorization' do
    context "GET /members FamilyMembers#destroy" do # hmm test here?
      it "able to remove a family from FamilyMember" do
        get '/v1/members'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
    context 'POST /familymember #authorize' do
      it 'admin can authorize new family members' do
        
      end
      it "doesn't allow the admin to update the 'authorized_at' timestamp once not null" do
        
      end
    end
  end
end