require 'rails_helper'

RSpec.describe 'POST /login', type: :request do
  before(:each) { host! 'api.example.com' }
  let(:member) { create(:member) }
  let(:url) { '/v1/login' }
  let(:params) do
    {
      member: {
        email: member.email,
        password: member.password
      }
    }
  end

  context 'when params are correct' do
    before do
      post url, params: params
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns JTW token in authorization header' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns valid JWT token' do
      decoded_token = decoded_jwt_token_from_response(response)
      expect(decoded_token.first['sub']).to be_present
    end
  end

  context 'when login params are incorrect' do
    before { post url }
    
    it 'returns unathorized status' do
      expect(response.status).to eq 401
    end
  end
end

RSpec.describe 'DELETE /logout', type: :request do
  before(:each) { host! 'api.example.com' }
  let(:url) { '/v1/logout' }
  it 'returns 204, no content' do
    delete url
    expect(response).to have_http_status(204)
  end
end