require 'thor'
require 'thor/actions'
require 's3crets/version'
require 's3crets/ui'
require 's3crets/actions'
require 's3crets/error'
require 's3crets/defaults'

module S3crets
  # The `s3crets` binay/thor application main class
  class Cli < Thor
    include Thor::Actions

    attr_accessor :ui

    def initialize(*)
      super
      the_shell = (options['no-color'] ? Thor::Shell::Basic.new : shell)
      @ui = Shell.new(the_shell)
      @ui.be_quiet! if options['quiet']
      @ui.debug! if options['verbose']

      debug_header
    end

    desc 'version', 'Display your Zanzibar verion'
    def version
      say "#{APPLICATION_NAME} Version: #{VERSION}"
    end

    desc 'init', "Create an empty #{SECRETFILE_NAME} in the current directory."
    option 'verbose', type: :boolean, default: false, aliases: :v
    option 'force', type: :boolean, default: false
    option 'bucket', type: :string, aliases: :b, default: 'my_bucket',
                     desc: 'The S3 bucket to connect to.'
    option 'region', type: :string, aliases: :r, default: 'us-west-2',
                     desc: 'The AWS region to use.'
    option 'noignore', type: :boolean, default: false, aliases: :i,
                       desc: "Don't write a .gitignore to the current directory."
    option 'credential_file', type: :string, aliases: :f,
                              default: '~/.aws/credential',
                              desc: 'The AWS credential file'
    def init
      run_action { init! }
    end

    desc 'bundle', "Fetch secrets declared in your #{SECRETFILE_NAME}"
    option 'verbose', type: :boolean, default: false, aliases: :v
    def bundle
      run_action { bundle! }
    end

    desc 'plunder', "Alias to `#{APPLICATION_NAME} bundle`", hide: true
    option 'verbose', type: :boolean, default: false, aliases: :v
    alias_method :plunder, :bundle

    desc 'install', "Alias to `#{APPLICATION_NAME} bundle`"
    alias_method :install, :bundle

    desc 'update', "Redownload all secrets in your #{SECRETFILE_NAME}"
    option 'verbose', type: :boolean, default: false, aliases: :v
    def update
      run_action { update! }
    end

    desc 'get KEY', 'Fetch a single KEY from S3'
    option 'bucket', type: :string, aliases: :b,
                     desc: 'The S3 bucket to connect to.'
    option 'region', type: :string, aliases: :r,
                     desc: 'The AWS region to use.'
    option 'credential_file', type: :string, aliases: :f,
                              default: '~/.aws/credential',
                              desc: 'The AWS credential file'
    def get(key)
      run_action { get! key }
    end

    private

    def debug_header
      @ui.debug { "Running #{APPLICATION_NAME} in debug mode..." }
      @ui.debug { "Ruby Version: #{RUBY_VERSION}" }
      @ui.debug { "Ruby Platform: #{RUBY_PLATFORM}" }
      @ui.debug { "#{APPLICATION_NAME} Version: #{VERSION}" }
    end

    # Run the specified action and rescue errors we
    # explicitly send back to format them
    def run_action(&_block)
      yield
    rescue ::S3crets::Error => e
      @ui.error e
      abort "Fatal error: #{e.message}"
    end

    def init!
      say "Initializing a new #{SECRETFILE_NAME} in the current directory..."
      Actions::Init.new(@ui, options).run
      say "Your #{SECRETFILE_NAME} has been created!"
      say 'You should check the settings and add your secrets.'
      say "Then run `#{APPLICATION_NAME} bundle` to fetch them."
    end

    def bundle!
      say "Checking for secrets declared in your #{SECRETFILE_NAME}..."
      Actions::Bundle.new(@ui, options).run
      say 'Finished downloading secrets!'
    end

    def update!
      say "Redownloading all secrets declared in your #{SECRETFILE_NAME}..."
      Actions::Bundle.new(@ui, options, update: true).run
      say 'Finished downloading secrets!'
    end

    def get!(path)
      say Actions::Get.new(@ui, options, path).run
    end
  end
end
