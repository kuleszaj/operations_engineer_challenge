require 'spec_helper'

describe 'Mapping Controller', type: :controller do
  describe 'Listing (Authorized)' do
    before do
      Mapping.new(tag: 'factsheet07',
                  url: 'https://example.com/fact-sheet-2015-07.pdf').save!
      Mapping.new(tag: 'factsheet09',
                  url: 'https://example.com/fact-sheet-2015-09.pdf').save!
      Mapping.new(tag: 'factsheet11',
                  url: 'https://example.com/fact-sheet-2015-11.pdf').save!
    end

    it 'returns a listing of all mappings in JSON' do
      authorize('atomic', 'atomic')
      get '/mappings'
      expect(last_response.status).to be 200
      expect(last_response.headers['Content-Type']).to eq 'application/json'
      expect(last_response.body).to match 'factsheet07'
      expect(last_response.body).to match 'factsheet09'
      expect(last_response.body).to match 'factsheet11'
      expect(last_response.body).to match 'fact-sheet-2015-07.pdf'
      expect(last_response.body).to match 'fact-sheet-2015-09.pdf'
      expect(last_response.body).to match 'fact-sheet-2015-11.pdf'
    end
  end

  describe 'Listing (Unauthorized)' do
    before do
      Mapping.new(tag: 'factsheet05',
                  url: 'https://example.com/fact-sheet-2015-05.pdf').save!
    end

    it 'returns 401 and does not return any mappings' do
      authorize('atomic', 'abc123')
      get '/mappings'
      expect(last_response.status).to be 401
      expect(last_response.body).to_not match 'factsheet05'
      expect(last_response.body).to_not match 'fact-sheet-2015-05.pdf'
    end
  end

  describe 'Redirects' do
    before do
      Mapping.new(tag: 'factsheet',
                  url: 'https://example.com/fact-sheet-2015-09.pdf').save!
      mapping = Mapping.new(url: 'https://example.com/fact-sheet-2015-13.pdf')
      mapping.save!
      @generated_tag = mapping.tag
    end

    it 'redirects to URL for an existing custom mapping' do
      get '/factsheet'
      expect(last_response.status).to be 301
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq 'https://example.com/fact-sheet-2015-09.pdf'
    end

    it 'redirects to URL for an existing generated mapping' do
      get "/#{@generated_tag}"
      expect(last_response.status).to be 301
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq 'https://example.com/fact-sheet-2015-13.pdf'
    end

    it 'returns 404 for a non-existing mapping' do
      get '/telephone'
      expect(last_response.status).to be 404
      expect(last_response).to_not be_redirect
    end

    it 'returns 404 for an invalid tag' do
      get '/this-is-an-invalid-tag'
      expect(last_response.status).to be 404
      expect(last_response).to_not be_redirect
    end
  end

  describe 'Creation (Authorized)' do
    before do
    end

    it 'returns 500 for an invalid url' do
      authorize('atomic', 'atomic')
      post '/mappings', tag: 'mytag', url: 'not-a-valid-url'
      expect(last_response.status).to be 500
    end

    it 'returns 500 for an invalid tag' do
      authorize('atomic', 'atomic')
      post '/mappings', tag: 'my-tag', url: 'https://google.com/'
      expect(last_response.status).to be 500
    end

    it 'allows creation of a custom mapping' do
      authorize('atomic', 'atomic')
      post '/mappings', tag: 'myfactsheet',
                        url: 'https://example.com/fact-sheet-2015-07.pdf'
      expect(last_response.status).to be 200
      expect(last_response.body).to eq '{"tag":"myfactsheet","url":"'\
      'https://example.com/fact-sheet-2015-07.pdf"}'

      get '/myfactsheet'
      expect(last_response.status).to be 301
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to \
        eq 'https://example.com/fact-sheet-2015-07.pdf'
    end

    it 'allows creation of a generated mapping' do
      authorize('atomic', 'atomic')
      post '/mappings', url: 'https://example.com/fact-sheet-2015-05.pdf'
      expect(last_response.status).to be 200
      expect(last_response.body).to match \
        %r({"tag":"(.*?)","url":"https://example.com/fact-sheet-2015-05.pdf"})x
    end

    it 'updates an existing custom (or generated) mapping'\
       'if it already exists' do
      authorize('atomic', 'atomic')
      post '/mappings', tag: 'myfactsheet',
                        url: 'https://example.com/fact-sheet-2015-07.pdf'
      expect(last_response.status).to be 200
      expect(last_response.body).to eq \
        '{"tag":"myfactsheet",'\
        '"url":"https://example.com/fact-sheet-2015-07.pdf"}'

      get '/myfactsheet'
      expect(last_response.status).to be 301
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to \
        eq 'https://example.com/fact-sheet-2015-07.pdf'

      post '/mappings', tag: 'myfactsheet',
                        url: 'https://example.com/fact-sheet-2015-11.pdf'
      expect(last_response.status).to be 200
      expect(last_response.body).to eq \
        '{"tag":"myfactsheet",'\
        '"url":"https://example.com/fact-sheet-2015-11.pdf"}'

      get '/myfactsheet'
      expect(last_response.status).to be 301
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq \
        'https://example.com/fact-sheet-2015-11.pdf'
    end
  end

  describe 'Creation (Unauthorized)' do
    it 'returns 401 when not authorized' do
      authorize('atomic', 'abc123')
      post '/mappings', tag: 'mytag', url: 'https://google.com/'
      expect(last_response.status).to be 401
    end

    it 'does not create a mapping when not authorized' do
      authorize('atomic', 'abc123')
      post '/mappings', tag: 'mytag', url: 'https://google.com/'
      get '/mytag'
      expect(last_response.status).to be 404
    end
  end

  describe 'Legacy Redirects' do
    it 'redirects /shorten.php to /mappings' do
      post '/shorten.php'
      expect(last_response.status).to be 301
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq 'http://example.org/mappings'
    end

    it 'redirects /list.php to /mappings' do
      get '/list.php'
      expect(last_response.status).to be 301
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq 'http://example.org/mappings'
    end
  end

  describe 'Deletion (Authorized)' do
    before do
      Mapping.new(tag: 'exists',
                  url: 'https://example.com/fact-sheet-2015-11.pdf').save!
    end

    it 'returns 500 for an invalid tag' do
      authorize('atomic', 'atomic')
      delete '/mappings/not-valid'
      expect(last_response.status).to be 500
    end

    it 'returns 404 when a mapping is not found for deletion' do
      authorize('atomic', 'atomic')
      delete '/mappings/doesnotexist'
      expect(last_response.status).to be 404
    end

    it 'allows deletion of an existing mapping' do
      authorize('atomic', 'atomic')
      delete '/mappings/exists'
      expect(last_response.status).to be 204
      expect(Mapping.find_by_tag('exists')).to be nil
    end
  end

  describe 'Deletion (Unauthorized)' do
    before do
      Mapping.new(tag: 'mytesttag',
                  url: 'https://example.com/fact-sheet-2015-11.pdf').save!
    end

    it 'returns 401 when not authorized' do
      authorize('atomic', 'abc123')
      delete '/mappings/mytag'
      expect(last_response.status).to be 401
    end

    it 'does not delete a mapping when not authorized' do
      authorize('atomic', 'abc123')
      delete '/mappings/mytesttag'
      expect(last_response.status).to be 401
      expect(Mapping.find_by_tag('mytesttag')).to_not be nil
    end
  end
end
