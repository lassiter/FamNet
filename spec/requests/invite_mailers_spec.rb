require 'rails_helper'

RSpec.describe "InviteMailers", type: :request do

  describe '::Registration via Invite' do
    
  end
  describe '::InviteMailer' do
    describe "Invite#New" do
      it "works! (now write some real specs)" do
        get invite_mailers_path
        expect(response).to have_http_status(200)
      end
    end
    describe '::Invite#Create' do
      
    end
  end
end
