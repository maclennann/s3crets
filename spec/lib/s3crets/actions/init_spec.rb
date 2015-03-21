require 's3crets/cli'
require 's3crets/defaults'
require 'rspec'
require 'fakefs/spec_helpers'

describe S3crets::Cli do
  include FakeFS::SpecHelpers

  describe '#init' do
    before(:each) do
      templates_root = File.join(source_root, 'templates')
      FakeFS::FileSystem.clone templates_root
    end

    context 'when a file does not yet exist' do
      it 'should create a template file' do
        expect { subject.init }.to output(/has been created/).to_stdout
        expect(FakeFS::FileTest.file? S3crets::SECRETFILE_NAME).to be(true)
        expect(File.read S3crets::SECRETFILE_NAME).to match(/Fill in secrets/)
      end

      it 'should accept settings as options' do
        subject.options = { 'region' => 'us-east-1',
                            'bucket' => 'an_example_bucket',
                            'secretdir' => '.' }

        expect { subject.init }.to output(/has been created/).to_stdout
        contents = File.read S3crets::SECRETFILE_NAME
        expect(contents).to include('region: us-east-1')
        expect(contents).to include('bucket: an_example_bucket')
        expect(contents).to include('secret_dir: .')
      end
    end

    context 'when a file already exists' do
      before(:each) { File.write(S3crets::SECRETFILE_NAME, 'test value') }

      it 'should not overwrite an existing file' do
        expect { subject.init }.to raise_error.with_message(/#{S3crets::ALREADY_EXISTS_ERROR}/)
        expect(File.read S3crets::SECRETFILE_NAME).to eq('test value')
      end

      it 'should obey the force flag' do
        subject.options = { 'force' => true }

        expect { subject.init }.to output(/has been created/).to_stdout
        expect(File.read S3crets::SECRETFILE_NAME).to match('Fill in secrets')
      end
    end
  end
end
