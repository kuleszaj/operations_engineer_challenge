# Legacy redirect
post '/shorten.php' do
  redirect '/mappings', 301
end

# Legacy redirect
get '/list.php' do
  redirect '/mappings', 301
end

# Return all listings in a JSON structure.
get '/mappings' do
  protected!
  content_type :json
  Mapping.all.to_json
end

# If it's not a valid tag, return 404.
# Otherwise, try to look up the mapping using the provided tag.
# Redirect to URL associated with the mapping
get '/mappings/:tag' do
  tag = params[:tag]
  halt 404 unless valid_tag?(tag)
  mapping = Mapping.find_by_tag(tag)
  halt 404 if mapping.nil?
  logger.debug("Redirecting tag '#{tag}' to '#{mapping.url}'")
  redirect mapping.url, 301
end

# Create (or update) a new mapping using the provided tag and URL
# If no tag is provided, a new mapping will be created using the given
# URL and a generated tag.
# If both a tag and URL are provided, a new mapping with be creatd with
# them -- unless the tag is already in use. In which case, the
# mapping will be updated to associate the tag with the newly provided URL
post '/mappings' do
  protected!
  tag = params[:tag]
  url = params[:url]

  halt 500 unless valid_url?(url)
  halt 500 unless valid_tag?(tag) || tag.blank?

  mapping = Mapping.find_by_tag(tag)
  mapping = Mapping.new if mapping.nil?
  mapping.tag = tag unless tag.blank?
  mapping.url = url
  logger.debug("Creating/updating tag '#{tag}' "\
               "to correspond with '#{mapping.url}'")
  mapping.save!

  # Return a JSON representation of the new/changed mapping.
  content_type :json
  {
    tag: mapping.tag,
    url: mapping.url
  }.to_json
end

delete '/mappings/:tag' do
  protected!
  tag = params[:tag]

  halt 500 unless valid_tag?(tag)

  mapping = Mapping.find_by_tag(tag)

  halt 404 if mapping.nil?

  logger.debug("Deleting tag '#{tag}'")
  halt 204 if mapping.destroy!
end

# Internally redirect to /mapping/:tag
get %r{\A\/([0-9A-Za-z]{1,16})\z} do
  status, headers, body = call env.merge(PATH_INFO: "/mappings/#{params['captures'].first}")
  [status, headers, body.map(&:upcase)]
end
