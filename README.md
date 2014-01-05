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

### Convention Over Configuration

By default Chamber only needs a base path to look for settings files.  From
that path it will search for:

* The file `<basepath>/credentials.yml`
* The file `<basepath>/settings.yml`
* A set of files ending in `.yml` in the `<basepath>/settings` directory

### In Plain Old Ruby

```ruby
Chamber.load basepath: '/path/to/my/application'
```

### In Rails

If you're running a Rails app, by default Chamber will set the basepath to your
Rails app's `config` directory, which is the equivalent of:

```ruby
Chamber.load basepath: Rails.root.join('config')
```

### Accessing Settings

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
```

or via object notation syntax:

```ruby
Chamber.env.smtp.server
# => example.com
```

### Keeping Your Settings Files Secure

Check out [Keeping Private Settings Private](#keeping-private-settings-private)
below.

### Existing Environment Variables (aka Heroku)

If deploying to a system which has all of your environment variables already
set, you're not going to use all of the values stored in the YAML files.
Instead, you're going to want to pull certain values from environment variables.

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

## Deploying to Heroku

If you're deploying to Heroku, they won't let you upload custom config files. If
you do not have your config files all stored in your repo (which you shouldn't
if some of the information is sensitive), it becomes more difficult to gain
access to that information on Heroku.

To solve this problem, Heroku allows you to set environment variables in your
application.  Unfortunately this has the nasty side effect of being a pain to
deal with.  For one, you have to deal with environment variables with unweildy
names.  For another, it makes the organization of those variables difficult.

Fortunately, Chamber allows you to organize your environment variables in
separate files and access them easily using hash or object notation, however at
the same time, it provides a convenient way to push all of those sensitive
configuration settings up to Heroku as environment variables.

When Chamber accesses those same hash/object notated config values, it will
first look to see if an associated environment variable exists.  If it does, it
will use that in place of any values inside of the config files.

Simply run:

```sh
# In the root folder of your Rails app:

chamber heroku push --preset=rails

# In the root folder of another type of application:

chamber heroku push --basepath=./
```

And all of your settings will be converted to environment variable versions
and set on your Heroku app.

_**Note:** For the full set of options, see [The chamber Command Line
App](#the-chamber-command-line-app) below._

## Deploying to Travis CI

When deploying to Travis CI, it has similar environment variable requirements as
Heroku, however Travis allows the encryption of environment variables before
they are stored in the .travis.yml file.  This allows for that file to be
checked into git without worrying about prying eyes figuring out your secret
information.

To execute this, simply run:

```sh
chamber travis secure --basepath=./
```

This will add `secure` entries into your `.travis.yml` file.  Each one will
contain one environment variable.

_**Warning:** Each time you execute this command it will delete all secure
entries under 'env.global' in your `.travis.yml` file._

_**Note:** For the full set of options, see [The chamber Command Line
App](#the-chamber-command-line-app) below._

## Advanced Usage

### Explicitly Specifying Settings Files

Using convention over configuration, Chamber handles the 90% case by default,
however there may be times at which you would like to explicitly specify which
settings files are loaded.  In these cases, Chamber has you covered:

```ruby
Chamber.load files: [
                      '/path/to/my/application/chamber/credentials.yml',
                      '/path/to/my/application/application*.yml',
                      '/path/to/my/application/chamber/*.yml',
                    ]
```

In this case, Chamber will load *only* the `credentials.yml` file *without ever*
looking for a namespaced file.  Then it will load `application.yml` *and* any
associated namespaced files.  Finally it will load all \*.yml files in the
`chamber` directory *except* `credentials.yml` because it has previously been
loaded.

### Object-Based Environment Variable Access

If you aren't a fan of the hash-based access, you can also access them
using methods:

```ruby
Chamber.env.smtp.server
```

### Predicate Methods

When using object notation, all settings have `?` and `_` predicate methods
defined on them.  They work like so:

#### '?' Predicates Check For Falsity

```ruby
  Chamber.env.my_setting                    # => nil
  Chamber.env.my_setting?                   # => false

  Chamber.env.my_other_setting              # => false
  Chamber.env.my_other_setting?             # => false

  Chamber.env.another_setting               # => 'my value'
  Chamber.env.another_setting?              # => true
```

#### '\_' Predicates Allow for Multi-Level Testing

```ruby
  Chamber.env.empty?                        # => true
  Chamber.env.my_setting_group_.my_setting? # => false
```

#### 'key?' Checks For Existence

The `?` method will return false if a key has been set to `false` or `nil`. In
order to check if a key has been set at all, use the `key?('some_key')` method
instead.

Notice the difference:

```ruby
  Chamber.env.my_setting                    # => false
  Chamber.env.my_setting?                   # => false

  Chamber.env.key?('my_setting')            # => true
  Chamber.env.key?('my_non_existent_key')   # => false
```

### ERB Preprocessing

One of the nice things about Chamber is that it runs each settings file through
ERB before it tries to parse it as YAML.  The main benefit of this is that you
can use settings from previous files in ERB for later files.  This is mainly
used if you follow our convention of putting all of your sensitive information
in your `credentials.yml` file.

**Example:**

```yaml
# credentials.yml

production:
  my_secret_key: 123456789
```

```erb
<%# settings.yml %>

production:
  my_url: http://my_username:<%= Chamber[:my_secret_key] %>@my-url.com
```

Because by default Chamber processes `credentials` settings files before
anything else, this works.

But it's all ERB so you can do as much crazy ERB stuff in your settings files as
you'd like:

```erb
<%# settings.yml %>

<% %w{development test production}.each do |environment| %>
<%= environment %>:
  hostname_with_subdomain: <%= environment %>.example.com:3000

<% end %>
```

Would result in the following settings being set:

```yaml
development:
  hostname_with_subdomain: development.example.com:3000

test:
  hostname_with_subdomain: test.example.com:3000

production:
  hostname_with_subdomain: production.example.com:3000
```

### Namespacing

If, when running your app, you would like to have certain files loaded only
under specific circumstances, you can use Chamber's namespaces.

**Example:**

```ruby
Chamber.load( :basepath => '/tmp',
              :namespaces => {
                :environment => -> { ::Rails.env } } )
```

For this class, it will not only try and load the file `config/settings.yml`,
it will _also_ try and load the file `config/settings-<environment>.yml`
where `<environment>` is whatever Rails environment you happen to be running.

#### Inline Namespaces

If having a file per namespace value isn't your thing, you can inline your
namespaces.  Taking the example from above, rather than having `settings.yml`,
`settings-development.yml`, `settings-test.yml`, `settings-staging.yml` and
`settings-production.yml`, you could do something like this:

```yaml
# settings.yml

development:
  smtp:
    username: my_development_username
    password: my_development_password`

test:
  smtp:
    username: my_test_username
    password: my_test_password`

staging:
  smtp:
    username: my_staging_username
    password: my_staging_password`

production:
  smtp:
    username: my_production_username
    password: my_production_password`
```

You can even mix and match.

```yaml
# settings.yml

development:
  smtp:
    username: my_development_username
    password: my_development_password`

test:
  smtp:
    username: my_test_username
    password: my_test_password`

staging:
  smtp:
    username: my_staging_username
    password: my_staging_password`
```

```yaml
# settings-production.yml

smtp:
  username: my_production_username
  password: my_production_password`
````

The above will yield the same results, but allows you to keep the production
values in a separate file which can be secured separately.

#### Multiple Namespaces

Multiple namespaces can be defined by passing multiple items to the loader:

```ruby
Chamber.load( :basepath => '/tmp',
              :namespaces => {
                :environment => -> { ::Rails.env },
                :hostname    => -> { ENV['HOST'] } } )
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

The when you access the value with `Chamber[:smtp][:server]` you will receive
`testserver.com`.

### Outputting Your Settings

Chamber makes it dead simple to output your environment settings in a variety of
formats.

The simplest is:

```ruby
Chamber.to_s
# => MY_SETTING="my value" MY_OTHER_SETTING="my other value"
```

But you can pass other options to customize the string:

* `pair_separator`
* `value_surrounder`
* `name_value_separator`

```ruby
Chamber.to_s pair_separator:        "\n",
             value_surrounder:      "'",
             name_value_separator:  ': '

# => MY_SETTING: 'my value'
# => MY_OTHER_SETTING: 'my other value'
```

### The chamber Command Line App

Chamber provides a flexible binary that you can use to make working with your
configurations easier.  Let's take a look:

#### Common Options

Each of the commands described below takes a few common options.

* `--preset` (or `-p`): Allows you to quickly set the basepath, files and/or
  namespaces for a given situation (eg working with a Rails app).

  **Example:** `--preset=rails`

* `--files` (or `-f`): Allows you to specifically set the file patterns that
  Chamber should look at in determining where to load settings information from.

  **Example:** `--files=/path/to/my/application/secret.yml /path/to/my/application/settings/*.yml`

* `--basepath` (or `-b`): Sets the base path that Chamber will use to look for
  its [common settings files](#convention-over-configuration).

  **Example:** `--basepath=/path/to/my/application`

* `--namespaces` (or `-n`): The namespace values which will be considered for
  loading settings files.

  **Example:** `--namespaces=development`

_**Note:** `--basepath`, `--preset` and `--files` are mutually exclusive._

#### Settings

##### Settings Commands

###### Show

Gives users an easy way of looking at all of the settings that Chamber knows
about for a given context.  It will be output as a hash of hashes by default.

* `--as-env`: Instead of outputting the settings as a hash of hashes, convert
  the settings into environment variable-compatible versions.

  **Example:** `--as-env`

**Example:** `chamber settings show -p=rails`

###### Files

Very useful for troubleshooting, this will output all of the files that
Chamber considers relevant based on the given options passed.

Additionally, the order is significant.  Chamber will load settings from the
top down so any duplicate items in subsequent entries will override items from
previous ones.

**Example:** `chamber settings files -p=rails`

###### Compare

Will display a diff of the settings for one set of namespaces vs the settings
for a second set of namespaces.

This is extremely handy if, for example, you would like to see whether the
settings you're using for development match up with the settings you're using
for production, or if you're setting all of the same settings for any two
environments.

* `--keys-only`: This is the default.  When performing a comparison, only the
  keys will be considered since values between namespaces will often (and
  should often) be different.

  **Example:** `--keys-only`, `--no-keys-only`

* `--first`: This is an array of the first set of namespace settings that you
  would like to compare from.  You can list one or more.

  **Example:** `--first=development`, `--first=development my_host_name`

* `--second`: This is an array of the second set of namespace settings that
  you would like to compare against that specified by `--first`.  You can list
  one or more.

  **Example:** `--second=staging`, `--second=staging my_host_name`

**Example:** `chamber settings compare --first=development --second=staging -p=rails`

#### Heroku

As we described above, working with Heroku environment variables is tedious at
best.  Chamber gives you a few ways to help with that.

_**Note:** I'll be using the `--preset` shorthand `-p` for brevity below but the
examples will work with any of the other options described
[above](#common-options)._

##### Heroku Common Options

* `--app` (or `-a`): Heroku application name for which you would like to affect
  its environment variables.

  **Example:** `--app=my-heroku-app-name`

* `--dry-run` (or `-d`): The command will not actually execute, but will show
  you a summary of what *would* have happened.

  **Example:** `--dry-run`

* `--only-ignored` (or `-o`): This is the default.  Because Heroku has no issues
  reading from the config files you have stored in your repo, there is no need
  to set *all* of your settings as environment variables.  So by default,
  Chamber will only convert and push those settings which have been gitignored.

  To push everything, use the `--no-only-ignored` flag.

  **Example:** `--only-ignored`, `--no-only-ignored`

##### Heroku Commands

###### Push

As we described above, this command will take your current settings and push
them to Heroku as environment variables that Chamber will be able to
understand.

**Example:** `chamber heroku push -a=my-heroku-app -p=rails -n=staging`

_**Note:** To see exactly how Chamber sees your settings as environment variables, see
the [chamber settings show](#general-settings-commands) command above._

###### Pull

Will display the list of environment variables that you have set on your
Heroku instance.

This is similar to just executing `heroku config --shell` except that you can
specify the following option:

* `--into`: The file which the pulled settings will be copied into.  This file
  *will* be overridden.

  _**Note:** Eventually this will be parsed into YAML that Chamber can load
  straight away, but for now, it's basically just redirecting the output._

  **Example:** `--into=/path/to/my/app/settings/heroku.yml`

**Example:** `chamber heroku pull -a=my-heroku-app --into=/path/to/my/app/heroku.yml`

###### Diff

Will use git's diff function to display the difference between what Chamber
knows about locally and what Heroku currently has set.  This is very handy for
knowing what changes may be made if `chamber heroku push` is executed.

**Example:** `chamber heroku diff -a=my-heroku-app -p=rails -n=staging`

###### Clear

Will remove any environment variables from Heroku that Chamber knows about.
This is useful for clearing out Chamber-related settings without touching
Heroku addon-specific items.

**Example:** `chamber heroku clear -a=my-heroku-app -p=rails -n=staging`

#### Travis CI

##### Travis Common Options

* `--dry-run` (or `-d`): The command will not actually execute, but will show
  you a summary of what *would* have happened.

  **Example:** `--dry-run`

* `--only-ignored` (or `-o`): This is the default.  Because Travis has no issues
  reading from the config files you have stored in your repo, there is no need
  to set *all* of your settings as environment variables.  So by default,
  Chamber will only convert and push those settings which have been gitignored.

  To push everything, use the `--no-only-ignored` flag.

  **Example:** `--only-ignored`, `--no-only-ignored`

##### Travis Commands

###### Secure

Travis CI allows you to use the public key on your Travis repo to encrypt
items such as environment variables which you would like for Travis to be able
to have access to, but which you wouldn't necessarily want to be in plain text
inside of your repo.

This command takes the settings that Chamber knows about, encrypts them, and
puts them inside of your .travis.yml at which point they can be safely
committed.

_**Warning:** This will delete *all* of your previous 'secure' entries under
'env.global' in your .travis.yml file._

**Example:** `chamber travis secure -p=rails -n=continuous_integration`

### Basic Boolean Conversion

One of the things that is a huge pain when dealing with environment variables is
that they can only be strings.  Unfortunately this is kind of a problem for
settings which you would like to use to set whether a specific item is enabled
or disabled.  Because this:

```yaml
# settings.yml

my_feature:
  enabled: false
```

```ruby
if Chamber.env.my_feature.enabled?
  # Do stuff with my feature
end
```

Will always return true because `false` becomes `'false'` on Heroku which, as
far as Ruby is concerned, is `true`.  Now, you could completely omit the
`enabled` key, however this causes issues if you would like to audit your
settings (say for each environment) to make sure they are all the same.  Some
will have the `enabled` setting and some will not, which will give you false
positives.

You could work around it by doing this:

```ruby
if Chamber.env.my_feature.enabled == 'true'
  # Do stuff with my feature
end
```

but that looks awful.

To solve this problem, Chamber reviews all of your settings values and, if they
are any of the following exact strings (case insensitive):

* 'false'
* 'f'
* 'no'
* 'true'
* 't'
* 'yes'

The value will be converted to the proper Boolean value.  In which case the
above `Chamber.env.my_feature.enabled?` will work as expected and your
environment audit will pass.

### In Order to Add Advanced Functionality

In any case that you need to set configuration options or do advanced post
processing on your YAML data, you'll want to create your own object for
accessing it.  Don't worry, Chamber will take you 98% of the way there.

Just include it like so:

```ruby
class Settings < Chamber
end
```

Now, rather than using `Chamber[:application_host]` to access your
environment, you can simply use `Settings[:application_host]`.

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

We recommend adding the following to your `.gitignore` file:

```
# Ignore the environment-specific files that contain the real credentials:
/config/credentials.yml
/config/credentials-*.yml

# But don't ignore the example file that shows the structure:
!/config/credentials-example.yml
```

Along with any namespace-specific exclusions.  For example, if you're using
Rails, you may want to exclude some of your environment-specific files:

```
*-staging.yml
*-production.yml
```

### Full Example

Let's walk through how you might use Chamber to configure your SMTP settings:

```yaml
# config/settings.yml

stuff:
  not: "Not Related to SMTP"

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
Chamber[:smtp][:headers]
# => { X-MYAPP-NAME: 'My Application Name', X-MYAPP-STUFF: 'Other Stuff' }

Chamber[:smtp][:password]
# => my_test_password
```

## Alternatives

* [dotenv](https://github.com/bkeepers/dotenv)
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
