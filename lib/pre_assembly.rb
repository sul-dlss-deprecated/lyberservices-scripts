require 'fileutils'
require 'erb'

# these are the names of special datastream files that will be staged in the 'metadata' folder instead of the 'content' folder
METADATA_FILES=['descMetadata.xml','contentMetadata.xml'].map(&:downcase)

# auto require any project specific files
Dir[File.dirname(__FILE__) + '/pre_assembly/project/*.rb'].each {|file| require "pre_assembly/project/#{File.basename(file)}" }

require 'pre_assembly/reporting'
require 'pre_assembly/druid_minter'
require 'pre_assembly/bundle'
require 'pre_assembly/digital_object'
require 'pre_assembly/object_file'
require 'pre_assembly/remediation/remediate'
require 'pre_assembly/smpl_precontent_metadata'
require 'pre_assembly/utils'

require 'assembly-image'
require 'rest_client'
require 'honeybadger'

# Default assembly directory, can be overwritten by the value set in the project specific YAML configuration
ASSEMBLY_WORKSPACE = '/dor/assembly'

# Default technical metadata file present at root of each object directory
TECHNICAL_MD_FILE = 'technicalMetadata.xml'

# Default content metadata file present at root of each object directory
CONTENT_MD_FILE = 'contentMetadata.xml'

# Default descriptive metadata file present at root of each object directory
DESC_MD_FILE = 'descMetadata.xml'

module PreAssembly
  def self.retry_handler(method_name, logger, params = {})
    Proc.new do |exception, attempt_number, total_delay|
      logger.send "      ** #{method_name} FAILED **; with params of #{params.inspect}; and trying attempt #{attempt_number} of #{Settings.num_attempts}; delayed #{Dor::Config.dor.total_delay} seconds"
    end
  end

  UnknownError = Class.new(StandardError)
end
