# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3crets/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws-s3crets'
  spec.version       = S3crets::VERSION
  spec.authors       = ['Norm MacLennan']
  spec.email         = ['norm.maclennan@gmail.com']
  spec.summary       = 'Fetch secret files from AWS S3 buckets.'
  spec.description   = 'Fetch secret files from AWS S3 buckets.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.29'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'fakefs', '~> 0.6'
  spec.add_development_dependency 'gem-path', '~> 0.6'

  spec.add_dependency 'aws-sdk', '~> 2.0'
  spec.add_dependency 'thor'
end
