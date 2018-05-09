require 'digest/murmurhash'

# A mapping between a tag and URL
class Mapping < ActiveRecord::Base
  # Tag should be between 1 and 16 alphanumberic characters.
  validates :tag, uniqueness: true, length: { minimum: 1, maximum: 16 },
                  format: { with: /\A[0-9A-Za-z]{1,16}\z/ }
  # URL should be a valid URI
  validates :url, format: { with: URI.regexp }

  before_validation :strip_whitespace

  def initialize(attributes = {}, options = {})
    super
    # If there is no provided tag, initialize one
    # Use the URL to generate a tag if provided
    # Otherwise use a random one.
    new_tag = Digest::MurmurHash2.hexdigest(url) unless url.nil?
    new_tag = SecureRandom.hex(4) if url.nil?
    self.tag = new_tag if tag.nil?
  end

  private

  def strip_whitespace
    self.tag = tag.strip unless tag.nil?
    self.url = url.strip unless url.nil?
  end
end
