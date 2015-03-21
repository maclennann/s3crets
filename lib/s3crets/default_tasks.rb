require 's3crets/cli'

namespace :secrets do
  env_glob = ENV['S3CRETS_ENVIRONMENT_GLOB'] || 'secrets/**/Secretfile'
  environments = (Dir.glob env_glob).map { |f| File.dirname f }.uniq

  environments.each do |env|
    short_name = File.basename env

    desc "Fetch secrets for #{short_name}"
    task "#{short_name}" do
      puts "CHDIR #{env}"
      Dir.chdir env do
        (S3crets::Cli.new).install
      end
    end
  end
end
