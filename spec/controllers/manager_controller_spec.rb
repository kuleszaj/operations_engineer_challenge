require 'spec_helper'

describe 'Manager Controller', type: :controller do
  describe 'Manager (Authorized)' do
    it 'returns the management form' do
      authorize('atomic', 'atomic')
      get '/admin/manager'
      expect(last_response.status).to be 200
      expect(last_response.body). to match('URL Shortener')
    end
  end

  describe 'Manager (Unauthorized)' do
    it 'does not allow access' do
      authorize('atomic', 'abc123')
      get '/admin/manager'
      expect(last_response.status).to be 401
    end
  end

  describe 'Legacy Redirects' do
    it 'redirects /manager.html to /admin/manager' do
      get '/manager.html'
      expect(last_response.status).to be 302
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq 'http://example.org/admin/manager'
    end
  end
end
