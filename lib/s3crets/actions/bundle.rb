require 's3crets/actions/base'
require 's3crets/error'
require 'aws-sdk'
require 'yaml'

module S3crets
  module Actions
    # Download or verify the secrets in a Secretfile
    class Bundle < Base
      attr_accessor :settings
      attr_accessor :remote_secrets
      attr_accessor :local_secrets
      attr_accessor :update

      def initialize(ui, options, args = {})
        super(ui, options)
        @update = args[:update]
      end

      def run
        ensure_secretfile
        load_required_secrets
        ensure_secrets_path
        validate_environment
        load_resolved_secrets if resolved_file?
        validate_local_secrets unless @update
        run!
      end

      private

      def run!
        if need_secrets?
          new_secrets = download_remote_secrets
          update_resolved_file new_secrets
        else
          debug { 'No secrets to download...' }
        end
      end

      def ensure_secretfile
        fail Error, NO_SECRETFILE_ERROR unless File.exist? SECRETFILE_NAME
        debug { "#{SECRETFILE_NAME} located..." }
      end

      def ensure_secrets_path
        FileUtils.mkdir_p(@settings['secret_dir']) unless @settings['secret_dir'].nil?
      end

      def resolved_file?
        File.exist? RESOLVED_NAME
      end

      def load_required_secrets
        secretfile = YAML.load_file(SECRETFILE_NAME)
        @settings = secretfile['settings'] || {}
        @remote_secrets = secretfile['secrets'] || {}
        @local_secrets = {}
      end

      def validate_environment
        return unless @settings.empty? || @remote_secrets.empty?
        fail Error, INVALID_SECRETFILE_ERROR
      end

      def load_resolved_secrets
        @local_secrets = YAML.load_file RESOLVED_NAME
      end

      def need_secrets?
        !@remote_secrets.empty?
      end

      def validate_local_secrets
        @local_secrets.each do |key, secret|
          if File.exist?(secret[:path]) && secret[:hash] == Digest::MD5.file(secret[:path]).hexdigest
            debug { "#{key} found locally, skipping download..." }
            @remote_secrets.delete key
          end
        end
      end

      def download_remote_secrets
        downloaded_secrets = {}
        remote_secrets.each do |key, secret|
          downloaded_secrets[key] = download_one_secret(secret,
                                                        @settings['secret_dir'] || '.')

          debug { "Downloaded secret: #{key} to #{@settings['secret_dir']}..." }
        end

        downloaded_secrets
      end

      def download_one_secret(remote_path, local_path)
        path = File.join(local_path, File.basename(remote_path))

        resp = s3.get_object(bucket: @settings['bucket'],
                             key: remote_path)

        File.write(path, resp.body.read)
        { path: path, hash: Digest::MD5.file(path).hexdigest }
      end

      def update_resolved_file(new_secrets)
        @local_secrets.merge! new_secrets

        File.open(RESOLVED_NAME, 'w') do |out|
          YAML.dump(@local_secrets, out)
        end

        debug { 'Updated resolved file...' }
      end

      def s3
        @s3 ||= ::Aws::S3::Client.new(region: @settings['region'])
      end
    end
  end
end
