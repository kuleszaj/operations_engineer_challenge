helpers do
  def protected!
    if settings.https
      redirect request.url.gsub(%r{http://}, 'https://'), 301 \
                                unless request.secure?
      logger.debug('Redirecting to https.')
    end
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  private

  def authorized?
    prep_auth!
    logger.debug("Attempting to authenticate: #{@auth.credentials[0]}") \
      if auth_provided?
    auth_provided? && @auth.credentials[0] == 'atomic' && \
      @auth.credentials[1] == 'atomic'
  end

  def prep_auth!
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
  end

  def auth_provided?
    @auth.provided? && @auth.basic? && @auth.credentials
  end
end
