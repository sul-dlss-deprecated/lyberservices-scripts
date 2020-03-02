source 'https://rubygems.org'

gem 'actionmailer', '~> 5.2'
gem 'actionpack', '~> 5.2'
gem 'csv-mapper'
gem 'config'
gem 'equivalent-xml'
gem 'honeybadger', '~> 3.1'
gem 'nokogiri'
gem 'pry-byebug' # helpful for debugging problems
gem 'rake'
gem 'rest-client'
gem 'retries'
gem 'roo'

# Stanford gems
gem 'assembly-image'
gem 'assembly-objectfile', '~> 1.9'
# https://github.com/sul-dlss-deprecated/dir_validator  <-- it's not maintained
# gem 'dir_validator' # for possible use, per spec/test_data/project_config_fles/local_dev_rumsey.rb
gem 'dor-services', '~> 8'
gem 'dor-services-client'
gem 'dor-workflow-client'
gem 'druid-tools'

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
