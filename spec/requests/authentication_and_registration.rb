require 'rails_helper'

RSpec.describe "Authentication API", type: :request do

  let(:member) { create(:member) }
  let(:valid_member) { create(:member) }

  context 'Signing up' do
    # before(:all) do
    #   Rails.cache.clear
    # end
    context 'with a valid registration' do
      it 'sucessfully creates an family and account with authorization_enabled set to true by default' do
        new_member = {:family => {family_name: "Test"}, :registration => {"email" => "newmember@example.com", "password" => "password", "name" => "name", "surname" => "surname"}}
        post '/v1/auth', params: new_member
        json = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        family_id = Family.find_by(family_name: "Test").id
        member_id = json["data"]["id"]
        expect(Member.exists?(id: json["data"]["id"])).to eq(true)
        expect(FamilyMember.exists?(member_id: json["data"]["id"])).to eq(true)
        expect(FamilyConfig.exists?(family_id: family_id)).to eq(true)
        binding.pry
        expect(FamilyConfig.find_by(family_id: family_id).authorization_enabled).to eq(true)
      end
      it 'sucessfully creates an family and account with authorization_enabled set to false' do
        new_member = {:family => {family_name: "Test", config: {:authorization_enabled => false}}, :registration => {"email" => "newmember@example.com", "password" => "password", "name" => "name", "surname" => "surname"}}
        post '/v1/auth', params: new_member
        json = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        family_id = Family.find_by(family_name: "Test").id
        member_id = json["data"]["id"]
        expect(Member.exists?(id: json["data"]["id"])).to eq(true)
        expect(FamilyMember.exists?(member_id: json["data"]["id"])).to eq(true)
        expect(FamilyMember.find_by(member_id: json["data"]["id"]).authorized_at).to_not eq(nil)
        expect(FamilyConfig.exists?(family_id: family_id)).to eq(true)
                binding.pry
        expect(FamilyConfig.find_by(family_id: family_id).authorization_enabled).to eq(false)
      end
      it 'sucessfully creates an account with an existing family' do
        family_id = FactoryBot.create(:family).id
        FamilyConfig.find_or_create_by(family_id: family_id)
        FactoryBot.create(:family_member, family_id: new_family.id, user_role: "owner", authorized_at: DateTime.now)
        new_member = {:family => {family_id: family_id}, :registration => {"email" => "newmember@example.com", "password" => "password", "name" => "name", "surname" => "surname"}}
        binding.pry
        post '/v1/auth', params: new_member
        json = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(FamilyMember.exists?(member_id: json["data"]["id"])).to eq(true)
        expect(FamilyMember.find_by(member_id: json["data"]["id"]).user_role).to eq("user")

      end
    end
    context 'with a invalid registration' do
      context 'with missing information' do
        new_member = {:family => {family_id: @family_id}, :registration => {"email" => "newmember@example.com", "password" => "password"}}
        it 'reports an error with a message' do
          post '/v1/auth', params: new_member

          expect(JSON.parse(response.body)).to include("errors")
          expect(response).to have_http_status(422)
        end
      end
      context 'non-unique information' do
        it 'reports non-unique email' do
          FactoryBot.create(:member, email: "newmember@example.com")
          new_member = {:family => {family_id: @family_id}, :registration => {"email" => "newmember@example.com", "password" => "password", "name" => "name", "surname" => "surname"}}

          post '/v1/auth', params: new_member
          expect(JSON.parse(response.body)).to include("errors")
          expect(response).to have_http_status(422)
        end
      end
    end
  end
  context 'Anon Access' do
    it 'accesses unprotected' do
    end
    it 'fails to access protected resources' do
      
    end
  end
  context 'Sign in' do
    before do
      post '/v1/auth/sign_in', { params: { "email" => valid_member.email, "password" => valid_member.password } }
      @header = response.header
    end
    context 'valid user login' do
      it 'allows user to login' do
        post '/v1/auth/sign_in', { params: { "email" => valid_member.email, "password" => valid_member.password } }
        expect(response).to have_http_status(200)
      end
      xit 'generates access token' do
      end
      xit 'grants access to resource' do
      end
      xit 'grants access to resource multiple times' do
      end
      it 'allows members to logout' do
        delete '/v1/auth/sign_out', { headers: { "uid" => valid_member.email, "client" => @header["client"], "access-token" => @header["access-token"] } }
        expect(response).to have_http_status(200)
      end
    end
    context 'invalid password' do
      it 'rejects credentials' do
        post '/v1/auth/sign_in', { params: { "email" => valid_member.email, "password" => "foobar" } }

        expect(JSON.parse(response.body)["errors"]).to include("Invalid login credentials. Please try again.")
        expect(response).to have_http_status(401)
      end
    end
  end

end
