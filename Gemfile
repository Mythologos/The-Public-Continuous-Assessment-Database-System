source 'https://rubygems.org'
git_source('Mythologos/Continuous-Assessment-Database-System') do |repo|
  "https://github.com/#{repo}.git"
end

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0.rc1'
# Use postgresql as the database for Active Record:
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server:
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets:
gem 'sass-rails', '~> 5'
# Transpile app-like JavaScript:
# Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster.
# Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production:
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password:
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant:
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb.
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code
  # to stop execution and get a debugger console.
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or
  # by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver.
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers.
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Windows does not support later versions of coffee-script.
gem 'coffee-script-source', '1.8.0'

# This is utilized to add primary keys that
# are more than one attribute without custom execute statements
# that are not integrated into the rest of RoR's setup.
# Would it be better to use Sequel (https://github.com/jeremyevans/sequel)?
gem 'composite_primary_keys', '>=12.0.0.rc5'

# This is used to read XLSX files.
gem 'simple_xlsx_reader', '>= 1.0.4'

# This is used for setting and managing environment variables.
# TODO: remove if not used.
gem 'dotenv-rails', groups: %i[development test production]

# The following gem allows for the generation of PDFs.
gem 'prawn', '>= 0.8.4'

# The following gem provides support for tables in prawn PDFs.
gem 'prawn-table'

# The following gem puts SVG files into PDFs.
gem 'prawn-svg', '>= 0.9.1'

# The gem prawn depends on:
gem 'pdf-core', '>= 0.7.0'
gem 'ttfunk', '>= 1.5'

# The following gem allows for the R programming language to be used in Ruby.
gem 'rinruby', '>= 2.1.0'

# The following gem is used to hash certain attributes for the database.
gem 'fnv-hash', '>= 0.2.0'