# Chamber [![Build Status](https://travis-ci.org/m5rk/chamber.png)](https://travis-ci.org/m5rk/chamber) [![Code Climate](https://codeclimate.com/github/m5rk/chamber.png)](https://codeclimate.com/github/m5rk/chamber)

Chamber is the auto-encrypting, extremely organizable, Heroku-loving, CLI-having,
non-extra-repo-needing, non-Rails-specific-ing, CI-serving configuration
management library.

## But What About Those Other Configuration Management Gems?

We reviewed [some other gems](#alternatives), and while each fit a specific need
and each did some things well, none of them met all of the criteria that we felt
we (and assumed others) needed.

<img src="https://akiajm7spx4gtbhaxe3qcomhaystacksoftwarearp.s3.amazonaws.com/photos/readmes/ten-commandments.png" align="right" />

**Our Ten Commandments of Configuration Management**

1. Thou shalt be configurable, but use conventions so that configuration isn't
   necessary
1. Thou shalt seemlessly work with Heroku or other deployment platforms, where custom
   settings must be stored in environment variables
1. Thou shalt seemlessly work with Travis CI and other cloud CI platforms
1. Thou shalt not force users to use arcane
   really_long_variable_names_just_to_keep_their_settings_organized
1. Thou shalt not require users keep a separate repo or cloud share sync just to
   keep their secure settings updated
1. Thou shalt not be bound to a single framework like Rails (it should be usable in
   plain Ruby projects)
1. Thou shalt have an easy-to-use CLI for scripting
1. Thou shalt easily integrate with Capistrano for easy configuration deployments
1. Thou shalt be well documented with full test coverage
1. Thou shalt not have to worry about accidentally committing secure settings

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

* The file `<basepath>/settings.yml`
* A set of files ending in `.yml` in the `<basepath>/settings` directory

### In Plain Old Ruby

```ruby
Chamber.load basepath: '/path/to/my/application'
```

### In Rails

You do not have to do anything.  Chamber will auto-configure itself to point to
the `config` directory.

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

### Securing Your Settings

Certain settings you will want to keep from prying eyes.  Unlike other
configuration management libraries, Chamber doesn't require you to keep those
files separate.  You can check *everything* into your repo.

Why is keeping your secure files separate a pain?  Because you must keep those
files in sync between all of your team members who are deploying the app.
Either you have to use a separate private repo, or you have to use something
like a Dropbox share.  In either case, you'd then symlink the files from their
locations into your application.  What. A. Pain.

Chamber uses public/private encryption keys to seemlessly store any of your
configuration values as encrypted text.  The only file that needs to be synced
*once* between developers is the private key.  And even that file would only be
needed by the users deploying the application.  If you're deploying via CI,
Github, etc, then technically no developer needs it.

#### Setting It Up

1. Create a Public/Private Keypair

  ```sh
  ssh-keygen -t rsa -C "your_email@example.com" -f ./.chamber_rsa
  ```

1. Create a Passphrase

  You'll now be asked for a passphrase, enter one and *remember it*. Preferably,
  store it in something like 1Password.

1. Set Proper File Permissions

  ```sh
  chmod 600 ./.chamber_rsa
  chmod 644 ./.chamber_rsa.pub
  ```

1. Add the Private Key to Your gitignore File

  ```sh
  echo ".chamber_rsa" >> .gitignore
  ```

#### Working With Secure Configuration Settings

Once your keypair is created, the hard work is done.  From here on out, Chamber
makes working with secure settings almost an afterthought.

When you create your configuration YAML file (or add a new setting to an
existing one), you can format your secure keys like so:

```yaml
# settings.yml

x_my_secure_key_name_x: 'my secure value'
```

When Chamber sees this convention (`x_` followed by the key name, followed by
`_x`), it will automatically look to either encrypt or decrypt the value using
the public/private keys you generated above into:

```yaml
# settings.yml

x_my_secure_key_name_x: 8239f293r9283r9823r92hf9823hf9uehfksdhviwuehf923uhrehf9238
```

However you would still have access the value like so (assuming you had access
to the private key):

```ruby
Chamber.env.my_secure_key_name
# => 'my secure value'
```

#### Git Commit Hooks

Chamber comes with a git commit hook which will automatically look in your repo
for standard Chamber settings files and, if it finds what it thinks to be an
unencrypted value that it believes you meant to be encrpyted, it will abort and
give you a chance to correct it (along with a command you can copy/paste to
fix the problem).

Add it to your project like so:

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
Chamber.load( :basepath => Rails.root.join('config'),
              :namespaces => {
                :environment => ::Rails.env } )
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
values in a separate file which can be secured separately. Although I would
recommend keeping everything together and just [encrpyting your sensitive
info](#securing-your-settings)

If you would like to have items shared among namespaces, you can easily use
YAML's built-in merge functionality to do that for you:

```yaml
# settings.yml

default: &shared
  smtp:
    headers:
      X-MYAPP-NAME: My Application Name
      X-MYAPP-STUFF: Other Stuff

development:
  <<: *shared
  smtp:
    username: my_development_username
    password: my_development_password`

test:
  <<: *shared
  smtp:
    username: my_test_username
    password: my_test_password`

staging:
  <<: *shared
  smtp:
    username: my_staging_username
    password: my_staging_password`
```

#### Multiple Namespaces

Multiple namespaces can be defined by passing multiple items to the loader:

```ruby
Chamber.load( :basepath => Rails.root.join('config'),
              :namespaces => {
                :environment => ::Rails.env,
                :hostname    => ENV['HOST'] } )
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

* `--keypair` (or `-k`): The path to the keypair to use for
  encryption/decryption. This is optional unless you have secure settings. You
  only have to point it to the public key. It will assume that the private key
  is the filename of the public key with any extension removed.

  **Example:** `--keypair=/path/to/my/app/my_project_rsa.pub`

_**Note:** `--basepath`, `--preset` and `--files` are mutually exclusive._

#### Settings

##### Settings Commands

###### Show

Gives users an easy way of looking at all of the settings that Chamber knows
about for a given context.  It will be output as a hash of hashes by default.

* `--as-env`: Instead of outputting the settings as a hash of hashes, convert
  the settings into environment variable-compatible versions.

  **Example:** `--as-env`

* `--auto-decrypt`: This is the default if the keypair provided includes
  a private key. Otherwise this is disabled.

**Example:** `chamber settings show -p=rails`

###### Files

Very useful for troubleshooting, this will output all of the files that
Chamber considers relevant based on the given options passed.

Additionally, the order is significant.  Chamber will load settings from the
top down so any duplicate items in subsequent entries will override items from
previous ones.

**Example:** `chamber settings files -p=rails`

###### Secure

Will verify that any items which are marked as secure (eg `x_my_setting_x`) have
secure values.  If it appears that one does not, the user will be prompted as to
whether or not they would like to encrpyt it.

Items which are marked as secure can specify this convention `x__my_setting__x`
to tell Chamber to always assume that the value is encrpyted, even if it appears
that it is not.

This command differs from other tasks in that it will process all files that
match Chamber's conventions and not just those which match the passed in
namespaces.

* `--auto-encrypt`: Will automatically encrypt any values which Chamber feels
  are unencrypted.

  **Example:** `--auto-encrypt`, `--skip-auto-encrypt`

* `--verify`: If the user has access to the private key, Chamber can decrypt the
  value and ensure it matches the original value. This is useful to doublecheck
  that the keypairs belong together.

  **Example:** `--verify`, `--skip-verify`

**Example:** `chamber settings secure -p=rails --verify --auto-encrypt`

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

* `--secure-only` (or `-o`): This is the default.  Because Heroku has no issues
  reading from the config files you have stored in your repo, there is no need
  to set *all* of your settings as environment variables.  So by default,
  Chamber will only convert and push those settings which have been gitignored
  or those which have been encrpyted.

  To push everything, use the `--skip-secure-only` flag.

  **Example:** `--secure-only`, `--skip-secure-only`

##### Heroku Commands

###### Push

As we described above, this command will take your current settings and push
them to Heroku as environment variables that Chamber will be able to
understand.

* `--strict`: This is the default. If strict mode is enabled and there are both
  secure settings *and* the private key cannot be found, the command will abort.

  **Example:** `--strict`, `--no-strict`

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

* `--secure-only` (or `-o`): This is the default.  Because Travis has no issues
  reading from the config files you have stored in your repo, there is no need
  to set *all* of your settings as environment variables.  So by default,
  Chamber will only convert and push those settings which have been gitignored
  or those which have been encrpyted.

  To push everything, use the `--skip-secure-only` flag.

  **Example:** `--secure-only`, `--skip-secure-only`

* `--strict`: This is the default. If strict mode is enabled and there are both
  secure settings *and* the private key cannot be found, the command will abort.

  **Example:** `--strict`, `--no-strict`

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
class Settings
  extend Chamber
end
```

Now, rather than using `Chamber[:application_host]` to access your
environment, you can simply use `Settings[:application_host]`.

## Best Practices

### Organizing Your Settings

We recommend starting with a single `settings.yml` file. Once this file begins
to become too unwieldy, you can begin to extract common options (let's say SMTP
settings) into another file (perhaps `settings/smtp.yml`).

### Full Example

Let's walk through how you might use Chamber to configure your SMTP settings:

```yaml
# config/settings.yml

stuff:
  not: "Not Related to SMTP"
```

```yaml
# config/settings/smtp.yml

default: &shared
  smtp:
    headers:
      X-MYAPP-NAME: My Application Name
      X-MYAPP-STUFF: Other Stuff

development:
  <<: *shared
  smtp:
    username: my_dev_user
    password: my_dev_password

staging:
  <<: *shared
  smtp:
    x_username_x: my_staging_user
    x_password_x: my_staging_password

production:
  <<: *shared
  smtp:
    x_username_x: my_production_user
    x_password_x: my_production_password
```

Now, assuming you're running in staging, you can access both `username` and
`headers` off of `smtp` like so:

```ruby
Chamber[:smtp][:headers]
# => { X-MYAPP-NAME: 'My Application Name', X-MYAPP-STUFF: 'Other Stuff' }

Chamber[:smtp][:username]
# => my_staging_username

Chamber[:smtp][:password]
# => my_staging_password
```

## Alternatives

* [dotenv](https://github.com/bkeepers/dotenv)
* [figaro](https://github.com/laserlemon/figaro)
* [idkfa](https://github.com/bendyworks/idkfa)
* [settingslogic](https://github.com/binarylogic/settingslogic)

## Thanks

Special thanks to all those gem authors above @binarylogic, @bendyworks,
@laserlemon and @bkeepers.  They gave us the inspiration to write this gem and
we would have made a lot more mistakes without them paving the way.  Thanks all!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
