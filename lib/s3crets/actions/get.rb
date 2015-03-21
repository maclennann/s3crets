require 's3crets/actions/base'
require 's3crets/error'
require 'aws-sdk'
require 's3crets/defaults'

module S3crets
  module Actions
    # Fetch a single secret
    class Get < Base
      attr_accessor :path

      def initialize(ui, options, path)
        super(ui, options)
        @path = path
      end

      def run
        fetch_secret(@path)
      end

      def fetch_secret(path)
        filename = File.basename(path)

        s3 = ::Aws::S3::Client.new(region: options['region'])
        resp = s3.get_object(bucket: options['bucket'],
                             key: path)

        File.write(filename, resp.body.read)
      end
    end
  end
end
