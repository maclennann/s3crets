require 's3crets/cli'
require 's3crets/defaults'
require 'rspec'
require 'fakefs/spec_helpers'
require 'aws-sdk'

describe S3crets::Cli do
  include FakeFS::SpecHelpers

  describe '#bundle' do
    context 'when Secretfile already exists' do
      before(:each) do
        spec_root = File.join(source_root, 'spec')
        files = File.join(spec_root, 'files')
        FakeFS::FileSystem.clone files

        path = `gem path aws-sdk`.chomp
        FakeFS::FileSystem.clone path, path
        Dir.chdir File.join(source_root, 'spec', 'files')
      end

      before(:all) do
        Aws.config[:stub_responses] = true
      end

      it 'should have a Secretfile' do
        expect(FakeFS::FileTest.file? S3crets::SECRETFILE_NAME).to be(true)
        expect(File.read(S3crets::SECRETFILE_NAME)).to include('testbucket')
      end

      xit 'should download a file' do
        expect(FakeFS::FileTest.file? File.join('secrets', '1.txt')).to be(false)
        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(FakeFS::FileTest.file? File.join('secrets', '1.txt')).to be(true)
      end

      xit 'should create a resolved file' do
        expect(FakeFS::FileTest.file? S3crets::RESOLVED_NAME).to be(false)
        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(FakeFS::FileTest.file? S3crets::RESOLVED_NAME).to be(true)
      end

      it 'should reject a malformed Secretfile' do
        File.write('Secretfile', 'broken YAML')
        expect { subject.bundle }.to raise_error.with_message(/#{S3crets::INVALID_SECRETFILE_ERROR}/)
      end
    end

    context 'when Secretfile does not exist' do
      it 'should return an error' do
        expect { subject.bundle }.to raise_error.with_message(/#{S3crets::NO_SECRETFILE_ERROR}/)
      end
    end
  end
end
