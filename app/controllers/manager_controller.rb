# Legacy redirect
get '/manager.html' do
  redirect '/admin/manager', 302
end

# Show the manager page
get '/admin/manager' do
  protected!
  haml :manager
end
