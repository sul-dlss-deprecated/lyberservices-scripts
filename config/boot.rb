require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'logger'

environment  = ENV['ROBOT_ENVIRONMENT'] ||= 'development'
PRE_ASSEMBLY_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
CERT_DIR = File.join(File.dirname(__FILE__), ".", "certs")

# General DLSS infrastructure.
require 'dor/workflow/client'

# Project dir in load path.
$LOAD_PATH.unshift(PRE_ASSEMBLY_ROOT + '/lib')

# Set up project logger.
require 'pre_assembly/logging'
PreAssembly::Logging.setup PRE_ASSEMBLY_ROOT, environment

# Development dependencies.
require 'awesome_print' if ['local', 'development'].include? environment

# Load the project and its dependencies.
require 'pre_assembly'


Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = 'Settings'
  # Load environment variables from the `ENV` object and override any settings defined in files.
  #
  config.use_env = true

  # Define ENV variable prefix deciding which variables to load into config.
  #
  config.env_prefix = 'SETTINGS'

  # What string to use as level separator for settings loaded from ENV variables. Default value of '.' works well
  # with Heroku, but you might want to change it for example for '__' to easy override settings from command line, where
  # using dots in variable names might not be allowed (eg. Bash).
  #
  config.env_separator = '__'
end

Config.load_and_set_settings(
  Config.setting_files(File.expand_path(__dir__), environment)
)

require "#{PRE_ASSEMBLY_ROOT}/config/environments/#{environment}.rb"

Dor::Services::Client.configure(url: Settings.dor_services.url,
                                token: Settings.dor_services.token)
