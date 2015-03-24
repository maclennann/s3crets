# S3crets

[![Build Status](https://travis-ci.org/maclennann/s3crets.svg?branch=master)](https://travis-ci.org/maclennann/s3crets)
[![Code Climate](https://codeclimate.com/github/maclennann/s3crets/badges/gpa.svg)](https://codeclimate.com/github/maclennann/s3crets)
[![Test Coverage](https://codeclimate.com/github/maclennann/s3crets/badges/coverage.svg)](https://codeclimate.com/github/maclennann/s3crets)

`s3crets` is a gem that allows you to fetch secret files (password, certs, keys,
etc) from an S3 bucket via the command-line, rake, or ruby script.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws-s3crets'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aws-s3crets

## Usage

### Setup

The most-common use-case for `s3crets` involves the use of a `Secretfile`.

This is a yaml file that contains S3 location information (region/bucket)
as well as the key/path to all of your required secrets.

You can generate a sample `Secretfile` by running `s3crets init`. Now you can
fill in your secrets. A completed `Secretfile` looks something like:

```yaml
---
settings:
  bucket: 'secrets_bucket'
  region: 'us-west-2'
  secret_dir: secrets/dev
secrets:
  aws_key: 'AWS/Keys/ec2-myteam-write'
  ssh_key: 'SSH/myteam/myserver/server-priv'
  cloud_config: 'AWS/cloudinit/myserver.yaml'
```

This `Secretfile` describes 3 secrets stored in the `secrets_bucket` bucket.
In this example, the files are 3 secrets required to provision a new EC2 instance -
an AWS credential file, an SSH private key, and a cloud-init config.

It will download these secrets to `secrets/dev/[filename]`.

### Fetching Secrets

Once you have your `Secretfile` ready, there are two ways you can actually fetch
the secrets. Both ways, assume you have your [AWS credentials set up](http://docs.aws.amazon.com/sdkforruby/api/#Credentials).

#### Command Line

Just type `s3crets bundle` to download all of the secrets. Secrets that already exist
in the target directory will not be re-downloaded.

#### Rake

`s3crets` comes with default rake tasks. Simply `require 's3crets/default_tasks'`
somewhere in your Rakefile and it will construct tasks based on your folder
structure and the location of your `Secretfile`(s).

For example, the following directory hierarchy:

```
Rakefile
secrets/
    production/
        Secretfile
    development/
        Secretfile
```

Will create the following rake tasks:

```
rake secrets:development   # Fetch secrets for development
rake secrets:production    # Fetch secrets for production
```

The following configuration can be applied to the default tasks:

* `ENV['S3CRETS_ENVIRONMENT_GLOB']` - The directory glob that is used to identify
your environments (default: `secrets/**/Secretfile`)

### `Secretfile.resolved`

Once you have fetched your secrets, a `Secretsfile.resolved` will be created in
the directory. This file contains the name and hash of the files that were
downloaded.

If you have a file locally that doesn't match the hash in your `resolved` file,
it will be redownloaded the next time you fetch secrets. Then the resolved file
will be updated.

## Contributing

1. Fork it ( https://github.com/maclennann/s3crets/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
