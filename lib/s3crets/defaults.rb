require 'pathname'

# Definitions for various strings used throughout the gem
module S3crets
  APPLICATION_NAME = Pathname.new($PROGRAM_NAME).basename
  SECRETFILE_NAME = 'Secretfile'
  RESOLVED_NAME = 'Secretfile.resolved'
  TEMPLATE_NAME = 'templates/Secretfile.erb'
  DEFAULT_REGION = 'us-west-2'
  DEFAULT_BUCKET = 'bucketname'

  ALREADY_EXISTS_ERROR = "#{SECRETFILE_NAME} already exists! Aborting..."
  NO_BUCKET_ERROR = 'Could not identify S3 bucket.'
  NO_SECRETFILE_ERROR = "You don't have a #{SECRETFILE_NAME}! Run `#{APPLICATION_NAME} init` first!"
  INVALID_SECRETFILE_ERROR = "Unable to load your #{SECRETFILE_NAME}. Please ensure it is valid YAML."
end
