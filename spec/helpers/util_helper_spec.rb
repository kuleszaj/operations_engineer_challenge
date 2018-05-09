require 'spec_helper'

describe 'Util Helper', type: :helper do
  describe 'valid_tag?' do
    it 'can detect an invalid tag' do
      result = app.new.helpers.valid_tag?('17charsssssssssss')
      expect(result).to be false
    end

    it 'can detect a valid tag' do
      result = app.new.helpers.valid_tag?('16charssssssssss')
      expect(result).to be true
    end

    it 'handles blank tags' do
      result = app.new.helpers.valid_tag?('')
      expect(result).to be false
    end
  end

  describe 'valid_url?' do
    it 'can detect an invalid url' do
      result = app.new.helpers.valid_url?('google-com')
      expect(result).to be false
    end

    it 'can detect a valid url' do
      result = app.new.helpers.valid_url?('https://google.com')
      expect(result).to be true
    end

    it 'handles blank urls' do
      result = app.new.helpers.valid_url?('')
      expect(result).to be false
    end
  end
end
