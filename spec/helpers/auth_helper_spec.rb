require 'spec_helper'

describe 'Auth Helper', type: :helper do
  describe 'protect!' do
    before do
      app.set :https, false
    end

    it 'protects against unauthorized access' do
      allow_any_instance_of(app).to receive(:authorized?).and_return(false)
      get '/admin/manager'
      expect(last_response.headers['WWW-Authenticate']).to \
        eq 'Basic realm="Restricted Area"'
      expect(last_response.status).to be 401
    end

    it 'allows authorized access' do
      allow_any_instance_of(app).to receive(:authorized?).and_return(true)
      get '/admin/manager'
      expect(last_response.status).to be 200
    end

    it 'redirects to HTTPS in production if it is not in use' do
      allow_any_instance_of(app).to receive(:authorized?).and_return(true)
      app.set :https, true
      get '/admin/manager'
      expect(last_response.status).to be 301
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to match 'https://'
    end

    it 'it uses HTTPS in production if it is already in use' do
      allow_any_instance_of(app).to receive(:authorized?).and_return(true)
      app.set :https, true
      header 'X_FORWARDED_PROTO', 'https'
      get '/admin/manager'
      expect(last_response.status).to be 200
    end
  end

  describe 'authorized?' do
    before do
      app.set :https, false
    end

    it 'returns false if invalid credentials are provided' do
      authorize('user', 'wrongPassword')
      get '/admin/manager'
      expect(last_response.status).to be 401
    end

    it 'returns true if valid credentials are provided' do
      authorize('atomic', 'atomic')
      get '/admin/manager'
      expect(last_response.status).to be 200
    end
  end
end
