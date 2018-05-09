## The Atomic URL Shortener

The URL Shortener is a simple application designed to map specific tags to URL's. A tag can either be custom (specified), or generated (automatic).

A tag must be unique -- there cannot be duplicates. However, multiple tags may map to the same URL. All tags and URL's are stored in a MySQL database.

### Platform

- Ruby 2.2.4 app using Sinatra
- MySQL 5.7

### Configuration

- Database connectivity:
  - Specified via the `DATABASE_URL` environment variable, Heroku-style. e.g. mysql2://username:password@hostname:3306/url_shortener

### Running the App locally

Assuming Ruby 2.2.4 is available with Bundler:

- `bundle install --path=vendor/bundle`
- `bundle exec rake db:migrate` to run database migrations
  - (Presumes MySQL is running locally on port 3306, and can be authenticated to with `root` user and no password.)
- `bundle exec rake db:seed` to import database seed data
- `bundle exec thin start -p 3000 -e development` to start running on port 3000 with a `RACK_ENV` of development.

### Operation

- Routes:
  - GET / : Returns nothing.
  - GET /admin/manager : Returns the management interface (webpage). (Authentication required).
  - GET /mappings : Returns the list of all mappings as JSON. (Authentication required).
  - POST /mappings : Creates/updates mappings as specified in multipart/form-data fields 'tag' and 'url'. (Authentication required).
  - GET /:tag : Redirects to /mappings/:tag
  - GET /mappings/:tag : Looks up the specified tag in the database, and performns a 302 redirect to the associated URL. (Or a 404 if it is not found).
  - DELETE /mappings/:tag : Looks up the specified tag in the database, and deletes the associated mapping. (Or a 404 if it is not found). (Authentication required).
