require 'rubygems'
require 'bundler/setup'
require 'logger'

environment  = ENV['ROBOT_ENVIRONMENT'] ||= 'development'
PRE_ASSEMBLY_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
CERT_DIR = File.join(File.dirname(__FILE__), ".", "certs")

# General DLSS infrastructure.
require 'dor-services'
require 'dor/workflow/client'

# Project dir in load path.
$LOAD_PATH.unshift(PRE_ASSEMBLY_ROOT + '/lib')

# Set up project logger.
require 'pre_assembly/logging'
PreAssembly::Logging.setup PRE_ASSEMBLY_ROOT, environment

require 'pre_assembly/utils'

# Development dependencies.
require 'awesome_print' if ['local', 'development'].include? environment

# Load the project and its dependencies.
require 'pre_assembly'

# Environment.
unless defined?(NO_ENVIRONMENT)
  ENV_FILE = PRE_ASSEMBLY_ROOT + "/config/environments/#{environment}.rb"
  require ENV_FILE
  Dor::Services::Client.configure(url: Dor::Config.dor_services.url,
                                  token: Dor::Config.dor_services.token)
end
