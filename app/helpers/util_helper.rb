helpers do
  # Tags are between 1 and 16 alphanumeric characters
  def valid_tag?(tag)
    tag =~ /\A[0-9A-Za-z]{1,16}\z/ ? true : false
  end

  def valid_url?(url)
    url =~ URI.regexp ? true : false
  end
end
