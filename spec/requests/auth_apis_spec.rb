require 'rails_helper'

RSpec.describe "Authentication API", type: :request do
  context 'Signing up' do
    context 'valid registration' do
      it 'sucessfully creates an account' do
        
      end
    end
    context 'invalid registration' do
      context 'missing information' do
        it 'reports an error with a message' do
          
        end
      end
      context 'non-unique information' do
        it 'reports non-unique email' do
          
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
      let(:member) { create(:member) }
    end
    context 'valid user login' do
      it 'generates access token' do
        
      end
      it 'grants access to resource' do
        
      end
      it 'grants access to resource multiple times' do
        
      end
      it 'allows members to logout' do
        
      end
    end
    context 'invalid password' do
      it 'rejects credentials' do
        
      end
    end
  end

end
