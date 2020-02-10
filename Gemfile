source 'https://rubygems.org'

gem 'actionmailer', '~> 5.2'
gem 'actionpack', '~> 5.2'
gem 'csv-mapper'
gem 'equivalent-xml'
gem 'nokogiri'
gem 'rake'
# gem 'rdf' # seems we don't need this??
gem 'rest-client'
gem 'retries'
gem 'roo'
gem 'honeybadger', '~> 3.1'

# Stanford gems
gem 'assembly-image'
gem 'assembly-objectfile', '~> 1.9'
gem 'dir_validator'
gem 'dor-services', '~> 8'
gem 'dor-services-client'
gem 'dor-workflow-client'
gem 'druid-tools'
gem 'harvestdor'
gem 'modsulator'
gem 'stanford-mods'
gem 'config'
gem 'pry-byebug' # helpful for debugging problems

group :test do
  gem 'coveralls', require: false
  gem 'jettywrapper'
  gem 'rspec', '~> 3.0'
end

group :deployment do
  gem 'capistrano', "~> 3"
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'dlss-capistrano', '~> 3.1'
end

group :development do
  gem 'awesome_print'
end

group :development, :test do
  gem 'byebug'
  gem 'rubocop', '~> 0.79.0'
  gem 'rubocop-rspec'
end
