require 'spec_helper'

describe 'Index Controller', type: :controller do
  it 'returns a blank index' do
    get '/'
    expect(last_response.status).to be 200
    expect(last_response.body).to eq ''
  end
end
