# Chamber [![Build Status](https://travis-ci.org/stevenhallen/chamber.png)](https://travis-ci.org/stevenhallen/chamber)

Chamber lets you source your Settings from an arbitrary number of YAML files and
provides a simple mechanism for overriding settings from the ENV, which is
friendly to how Heroku addons work.

## Installation

Add this line to your application's Gemfile:

    gem 'chamber'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chamber

## Usage

The following instructions are for a Rails app hosted on heroku with both
staging and production heroku environments.

1.  Create a Settings class that extends Chamber in `app/models/settings.rb`:

        ```ruby
        class Settings
          extend Chamber
        end
        ```

1.  Create a `config/settings.yml` that has this structure:

        ```yaml
        development:
          some_setting: value for dev
          some_password:
            environment:  ENV_VAR_NAME
        test:
          some_setting: value for test
          some_password:
            environment:  ENV_VAR_NAME
        staging:
          some_setting: value for staging
          some_password:
            environment:  ENV_VAR_NAME
        production:
          some_setting: value for production
          some_password:
            environment:  ENV_VAR_NAME
        ```

1.  Call `source` in your Settings class:

        ```ruby
        class Settings
          extend Chamber

          source Rails.root.join('config', 'settings.yml'), namespace: Rails.env, override_from_environment: true
        end
        ```

1.  Add environment-specific files for development and test to supply the values
    for those environments.  Make sure to add these to .gitignore.

1.  Add another call to `source` for these files:

        ```ruby
        class Settings
          extend Chamber

          source Rails.root.join('config', 'settings.yml'), namespace: Rails.env, override_from_environment: true
          source Rails.root.join('config', "credentials-#{Rails.env}.yml")
        end
        ```

1.  Use `heroku config` to set the `ENV_VAR_NAME` value for the staging and
    production remotes.

1.  You access your settings in your code from `Settings.instance` (assuming you
    extended Chamber in a class named `Settings`).

    In other words, given a configuration file like this:

        ```yaml
        s3:
          access_key_id: value
          secret_access_key: value
          bucket: value
        ```

    the corresponding Paperclip configuration would look like this:

        ```ruby
        Paperclip::Attachment.default_options.merge!(
          storage: 's3',
          s3_credentials: {
            access_key_id: Settings.instance.s3.access_key_id,
            secret_access_key: Settings.instance.s3.secret_access_key
          },
          bucket: Settings.instance.s3.bucket,
          ...
        ```

## General Principles

### Support best practices with sensitive information

Generally this is expressed in this overly simplified form:  "Don't store
sensitive information in git."  A better way to say it is that you should store
sensitive information separate from non-sensitive information.  There's nothing
inherently wrong with storing sensitive information in git.  You just wouldn't
want to store it in a public repository.

If it weren't for this concern, managing settings would be trivial, easily
solved use any number of approaches (e.g., [like using YAML and ERB in an
initializer](http://urgetopunt.com/rails/2009/09/12/yaml-config-with-erb.html).

I recommend adding a pattern like this to `.gitignore`:

```
# Ignore the environment-specific files that contain the real credentials:
/config/credentials-*.yml

# But don't ignore the example file that shows the structure:
!/config/credentials-example.yml
```

You would then use Chamber like this:

```ruby
class Settings
  extend Chamber
  source Rails.root.join('config', "credentials-#{Rails.env}.yml")
end
```

### Support arbitrary organization

You should be able to organize your settings files however you like.  You want
one big jumbo settings.yml?  You can do that with Chamber.  You want a distinct
settings file for each specific concern?  You can do that too.

Chamber supports this by allowing:

1.  Arbitrary number of files:

        ```ruby
        class Settings
          extend Chamber

          source Rails.root.join('config', 'settings.yml')
          source Rails.root.join('config', 'facebook.yml')
          source Rails.root.join('config', 'twitter.yml')
          source Rails.root.join('config', 'google-plus.yml')
        end
        ```

1.  Environment-specific filenames (e.g., `settings-#{Rails.env}.yml`)

1.  Namespaces:

        ```ruby
        class Settings
          extend Chamber

          source Rails.root.join('config', 'settings.yml'), namespace: Rails.env
        end
        ```

### Support overriding setting values at runtime from ENV

[heroku](http://heroku.com) addons are configured from ENV.  To support this,
Chamber's `source` method provides an `override_from_environment` option; e.g.,

```ruby
class Settings
  extend Chamber

  source Rails.root.join('config', 'settings.yml'), override_from_environment: true
end
```

## Ideas

* Add a rake task for validating environments (do all environments have the same
  settings?)

* Add a rake task for setting Heroku environment variables.

## Alternatives

### figaro

[figaro](https://github.com/laserlemon/figaro)

### idkfa

[idkfa](https://github.com/bendyworks/idkfa)

### settingslogic

[settingslogic](https://github.com/binarylogic/settingslogic)

### Others?

I'd love to hear of other gems and/or approaches to settings!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
