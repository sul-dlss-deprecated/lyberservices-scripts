source 'https://rubygems.org'

gem 'actionmailer', '~> 5.2'
gem 'actionpack', '~> 5.2'
gem 'csv-mapper'
gem 'equivalent-xml'
gem 'nokogiri'
gem 'rake'
gem 'rdf'
gem 'rest-client'
gem 'retries'
gem 'roo'
gem 'honeybadger', '~> 3.1'

# Stanford gems
gem 'assembly-image'
gem 'assembly-objectfile', '>= 1.7.2' # 1.7.2 is the first version to support 3d content metadata generation
gem 'assembly-utils'
gem 'dir_validator'
# gem 'dor-fetcher'   # not supported anymore; only used by devel/get_dor_and_sdr_versions.rb script, which is not regularly used
gem 'dor-services', '< 6'
gem 'dor-services-client'
gem 'dor-workflow-client'
gem 'druid-tools'
gem 'harvestdor'
gem 'modsulator'
gem 'stanford-mods'

group :test do
  gem 'rspec', '~> 3.0'
  gem 'solr_wrapper'
  gem 'jettywrapper'
  gem 'coveralls', require: false
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
end
