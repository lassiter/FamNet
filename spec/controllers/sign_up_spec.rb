require 'rails_helper'

RSpec.describe 'POST /signup', type: :request do
  before(:each) { host! 'api.example.com' }
  let(:member) { create(:member) }
  let(:url) { '/v1/signup' }
  let(:params) do
    {
      member: {
        email: 'member@example.com',
        password: 'password'
      }
    }
  end

  context 'when member is unauthenticated' do
    before { post url, params: params }
    it 'returns 200' do
      expect(response.status).to eq 200
    end

    it 'returns a new member' do
      expect(response.body).to match_schema('member')
    end
  end

  context 'when member already exists' do
    before do
      create(:member, email: params[:member][:email])
      post url, params: params
    end

    it 'returns bad request status' do
      expect(response.status).to eq 400
    end

    it 'returns validation errors' do
      expect(json['errors'].first['title']).to eq('Bad Request')
    end
  end
end