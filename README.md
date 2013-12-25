# Chamber [![Build Status](https://travis-ci.org/m5rk/chamber.png)](https://travis-ci.org/m5rk/chamber) [![Code Climate](https://codeclimate.com/github/m5rk/chamber.png)](https://codeclimate.com/github/m5rk/chamber)

Chamber lets you source your settings from an arbitrary number of YAML files that
values convention over configuration and has an automatic mechanism for working
with Heroku's (or anyone else's) ENV variables.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chamber'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install chamber
```

## Basic Usage

If you're running a Rails app, by default Chamber will look for all of:

* A file in `config/settings.yml`
* A set of YAML files in the `config/settings` directory

The YAML data will be loaded and you will have access to the settings
through the `Chamber` class.

**Example:**

Given a `settings.yml` file containing:

```yaml
smtp:
  server: "example.com"
  username: "my_user"
  password: "my_pass"
```

can be accessed as follows:

```ruby
Chamber[:smtp][:server]
# => example.com

Chamber[:smtp][:server]
# => example.com
```

and will generate the following environment variables if they don't already
exist:

```sh
SMTP_SERVER
SMTP_USERNAME
SMTP_PASSWORD
```

If the environment variables *do* already exist, then their values will not
be overwritten.

### Existing Environment Variables (aka Heroku)

If deploying to a system which has all of your environment variables already
set, you're not going to use the values stored in the YAML files.  Instead,
you're going to want to pull whatever values the environment variables are
storing.

**Example:**

Given a `settings.yml` file containing:

```yaml
smtp:
  server: "example.com"
  username: "my_user"
  password: "my_pass"
```

If an environment variable is already set like so:

```sh
export SMTP_SERVER="myotherserverisapentium.com"
```

Then when you ask Chamber to give you the SMTP server:

```ruby
Chamber[:smtp][:server]
# => "myotherserverisapentium.com"
```

It will return not what is in the YAML file, but what is in the environment
variable.

## Advanced Usage

In any case that you need to set configuration options or do advanced post
processing on your YAML data, you'll want to create your own object for
accessing it.  Don't worry, Chamber will take you 98% of the way there.

### Enhancing a Class with Chamber

Just include it like so:

```ruby
class Settings
  include Chamber::Settings
end
```

Now, rather than using `Chamber[:application_host]` to access your
environment, you can simply use `Settings[:application_host]`.

### Namespacing

If, when running your app, you would like to have certain files loaded only
under specific circumstances, you can use Chamber's namespaces.

**Example:**

```ruby
class Settings
  include Chamber::Settings
  
  namespaces :environment
  
  def environment
    Rails.env
  end
end
```

For this class, it will not only try and load the file `config/settings.yml`,
it will _also_ try and load the file `config/settings-<environment>.yml`
where `<environment>` is whatever Rails environment you happen to be running.

#### Multiple Namespaces

Multiple namespaces can be defined by passing multiple items to the namespace
method:

```ruby
class Settings
  include Chamber::Settings
  
  namespaces :environment, :hostname
end
```

When accessed within the `test` environment on a system named `tumbleweed`, it
will load the following files in the following order:

* `settings.yml`
* `settings-test.yml`
* `settings-tumbleweed.yml`

If a file does not exist, it is skipped.

#### What Happens With Duplicate Entries?

Similarly named settings in later files can override settings defined in earlier
files.

If `settings.yml` contains a value:

```yaml
smtp:
  server: "generalserver.com"
```

And then `settings-test.yml` contains this:

```yaml
smtp:
  server: "testserver.com"
```

The when you access the value with `Settings[:smtp][:server]` you will receive
`testserver.com`.

## Best Practices

### Why Do We Need Chamber?

> Don't store sensitive information in git.

A better way to say it is that you should store sensitive information separate
from non-sensitive information.  There's nothing inherently wrong with storing
sensitive information in git.  You just wouldn't want to store it in a public
repository.

If it weren't for this concern, managing settings would be trivial, easily
solved use any number of approaches; e.g., [like using YAML and ERB in an
initializer](http://urgetopunt.com/rails/2009/09/12/yaml-config-with-erb.html).

### Organizing Your Settings

We recommend starting with a single `config/settings.yml` file. Once this file
begins to become too unwieldy, you can begin to extract common options (let's
say SMTP settings) into another file (perhaps `config/settings/smtp.yml`).

### Keeping Private Settings Private

Obviously the greater the number of files which need to be kept private the more
difficult it is to manage the settings.  Therefore we suggest beginning with one
private file that stores all of your credentials.

### Ignoring Settings Files

I recommend adding a pattern like this to `.gitignore`:

```gitignore
# Ignore the environment-specific files that contain the real credentials:
/config/credentials.yml
/config/credentials-*.yml

# But don't ignore the example file that shows the structure:
!/config/credentials-example.yml
```

### Full Example

Let's walk through how you might use Chamber to configure your SMTP settings:

```yaml
# config/settings/smtp.yml

stuff:
  not: "Related to SMTP"

# config/settings/smtp.yml

smtp:
  headers:
    X-MYAPP-NAME: My Application Name
    X-MYAPP-STUFF: Other Stuff
    
# config/settings/smtp-staging.yml

smtp:
  username: my_test_user
  password: my_test_password
```

Now you can access both `username` and `headers` off of `smtp` like so:

```ruby
Settings[:smtp][:headers]
# => { X-MYAPP-NAME: 'My Application Name', X-MYAPP-STUFF: 'Other Stuff' }

Settings[:smtp][:password]
# => my_test_password
```

## Ideas

* Add a rake task for validating environments (do all environments have the same
  settings?)
* Add a rake task for setting Heroku environment variables.

## Alternatives

* [figaro](https://github.com/laserlemon/figaro)
* [idkfa](https://github.com/bendyworks/idkfa)
* [settingslogic](https://github.com/binarylogic/settingslogic)

### Others?

I'd love to hear of other gems and/or approaches to settings!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
