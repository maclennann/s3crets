require 's3crets/actions/base'
require 's3crets/error'
require 'ostruct'
require 'erb'
require 's3crets/defaults'
require 'English'

module S3crets
  module Actions
    # Create a new Secretfile
    class Init < Base
      def run
        check_for_secretfile
        write_template
        write_gitignore if safe_to_gitignore
      end

      private

      def check_for_secretfile
        return unless File.exist?(SECRETFILE_NAME) && !options['force']
        fail Error, ALREADY_EXISTS_ERROR
      end

      def write_template
        template = TemplateRenderer.new(options)

        File.open(SECRETFILE_NAME, 'w') do |f|
          f.write template.render(File.read(source_root.join(TEMPLATE_NAME)))
        end
      end

      def write_gitignore
        template = TemplateRenderer.new(options)
        File.open('.gitignore', 'w') do |f|
          f.write template.render(File.read(source_root.join('templates/gitignore.erb')))
        end
      end

      # Allows us to easily feed our options hash
      # to an ERB
      class TemplateRenderer < OpenStruct
        def render(template)
          ERB.new(template).result(binding)
        end
      end

      private

      def git_repo?
        `git status`
        $CHILD_STATUS.success?
      rescue => _
        false
      end

      def safe_to_gitignore
        git_repo? && !File.exist?('.gitignore') && !options['noignore']
      end
    end
  end
end
