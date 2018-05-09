require 'spec_helper'

describe Mapping, type: :model do
  it { should validate_length_of :tag }
  it { should validate_uniqueness_of :tag }
  it { should allow_value('1').for(:tag) }
  it { should allow_value('16charssssssssss').for(:tag) }
  it { should allow_value('validtag1').for(:tag) }
  it { should_not allow_value('invalid-tag').for(:tag) }
  it { should_not allow_value('invalid.tag').for(:tag) }
  it { should_not allow_value('').for(:tag) }
  it { should_not allow_value('17charsssssssssss').for(:tag) }
  it { should allow_value('http://google.com').for(:url) }
  it { should allow_value('http://google.com/some/path').for(:url) }
  it { should_not allow_value('google.com').for(:url) }
  it { should_not allow_value('google.com/some/path').for(:url) }

  it 'should map a tag to a URL' do
    Mapping.new(tag: 'factsheet',
                url: 'https://example.com/fact-sheet-2015-09.pdf').save!
    tag_mapping = Mapping.find_by_tag('factsheet')
    expect(tag_mapping.url).to eq 'https://example.com/fact-sheet-2015-09.pdf'
  end

  it 'should generate a tag when none is provided' do
    mapping = Mapping.new(url: 'https://example.com/fact-sheet-2015-09.pdf')
    mapping.save
    expect(mapping.tag).to match(/[0-9a-zA-z]{8}/)
  end

  it 'should strip whitespace from tags' do
    mapping = Mapping.new(tag: "\tmytag",
                          url: 'https://example.com/fact-sheet-2015-09.pdf')
    mapping.save
    expect(mapping.tag).to eq 'mytag'
  end

  it 'should strip whitespace from urls' do
    mapping = Mapping.new(url: "\thttps://example.com/fact-sheet-2015-09.pdf")
    mapping.save
    expect(mapping.url).to eq 'https://example.com/fact-sheet-2015-09.pdf'
  end
end
