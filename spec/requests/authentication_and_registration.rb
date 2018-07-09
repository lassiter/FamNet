require 'rails_helper'

RSpec.describe "Authentication API", type: :request do

  let(:member) { create(:member) }
  let(:valid_member) { create(:member) }

  context 'Signing up' do
    @family_id = FactoryBot.create(:family).id
    context 'with a valid registration' do
      new_member = {:family => {family_id: @family_id}, :registration => {"email" => "newmember@example.com", "password" => "password", "name" => "name", "surname" => "surname"}}
      it 'sucessfully creates an account' do
        post '/v1/auth', params: new_member
        response.body
        expect(response).to have_http_status(200)
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
