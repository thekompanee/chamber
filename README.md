# Chamber [![Build Status](https://travis-ci.org/thekompanee/chamber.png)](https://travis-ci.org/thekompanee/chamber) [![Code Climate](https://codeclimate.com/github/thekompanee/chamber.png)](https://codeclimate.com/github/thekompanee/chamber) [![Code Climate](https://codeclimate.com/github/thekompanee/chamber/coverage.png)](https://codeclimate.com/github/thekompanee/chamber)

Chamber is the auto-encrypting, extremely organizable, Heroku-loving, CLI-having,
non-extra-repo-needing, non-Rails-specific-ing, CI-serving configuration
management library.

[![TrueFact](https://cloud.githubusercontent.com/assets/285582/4803823/ad8110fa-5e5e-11e4-90d6-59320045a786.png)](https://www.youtube.com/watch?v=NNG1OoH2RwE)

**Our Ten Commandments of Configuration Management**

<img src="https://akiajm7spx4gtbhaxe3qcomhaystacksoftwarearp.s3.amazonaws.com/photos/readmes/ten-commandments.png" align="right" />

1. Thou shalt be configurable, but [use conventions so that configuration isn't
   necessary](https://github.com/thekompanee/chamber/wiki/Basic-Usage#convention-over-configuration)
1. Thou shalt [seamlessly work with Heroku](https://github.com/thekompanee/chamber/wiki/Heroku) or other deployment platforms, where custom
   settings must be stored in [environment variables](https://github.com/thekompanee/chamber/wiki/Environment-Variable-Compatibility)
1. Thou shalt seamlessly work with [Travis CI](https://github.com/thekompanee/chamber/wiki/TravisCI) and other cloud CI platforms
1. Thou shalt not force users to use arcane
   [long_variables_to_keep_their_settings_organized](https://github.com/thekompanee/chamber/wiki/Accessing-Settings)
1. Thou shalt not require users keep a separate repo or cloud share sync [just to
   keep their secure settings updated](https://github.com/thekompanee/chamber/wiki/Encrypting-Your-Settings)
1. Thou shalt not be bound to a single framework like Rails (it should be usable [in
   plain Ruby projects](https://github.com/thekompanee/chamber/wiki/Basic-Usage#in-a-plain-old-ruby-project))
1. Thou shalt have an [easy-to-use CLI](https://github.com/thekompanee/chamber/wiki/Command-Line-Reference) for scripting
1. Thou shalt easily integrate with Capistrano for deployments
1. Thou shalt be [well documented](https://github.com/thekompanee/chamber/wiki/) with full test coverage
1. Thou shalt not have to worry about [accidentally committing secure settings](https://github.com/thekompanee/chamber/wiki/Git-Commit-Hook)

## Full Reference

1. [Why _another_ Configuration Management Gem?](https://github.com/thekompanee/chamber/wiki/Why-ANOTHER-Configuration-Management-Gem%3F)
1. [Installation](https://github.com/thekompanee/chamber/wiki/Installation)
  1. [Basic Usage](https://github.com/thekompanee/chamber/wiki/Basic-Usage)
  1. [Convention Over Configuration](https://github.com/thekompanee/chamber/wiki/Basic-Usage#convention-over-configuration)
  1. [In a Plain Old Ruby Project](https://github.com/thekompanee/chamber/wiki/Basic-Usage#in-a-plain-old-ruby-project)
  1. [In a Rails Project](https://github.com/thekompanee/chamber/wiki/Basic-Usage#in-a-rails-project)
  1. [In a Rails Engine](https://github.com/thekompanee/chamber/wiki/Basic-Usage#in-a-rails-engine)
1. [Accessing Settings](https://github.com/thekompanee/chamber/wiki/Accessing-Settings)
1. Securing Your Settings
  1. [Rationale](https://github.com/thekompanee/chamber/wiki/Rationale)
  1. [Encrypting Your Settings](https://github.com/thekompanee/chamber/wiki/Encrypting-Your-Settings)
  1. [Accessing Secure Settings](https://github.com/thekompanee/chamber/wiki/Accessing-Secure-Settings)
  1. [Git Commit Hook](https://github.com/thekompanee/chamber/wiki/Git-Commit-Hook)
  1. [The Protected Key](https://github.com/thekompanee/chamber/wiki/Protected-Keys)
1. [Environment Variable Compatibility](https://github.com/thekompanee/chamber/wiki/Environment-Variable-Compatibility)
1. Integrations
  1. [Heroku](https://github.com/thekompanee/chamber/wiki/Heroku)
  1. [TravisCI](https://github.com/thekompanee/chamber/wiki/TravisCI)
  1. [CircleCI](https://github.com/thekompanee/chamber/wiki/CircleCI)
1. Best Practices
  1. [Organizing Your Settings](https://github.com/thekompanee/chamber/wiki/Organizing-Your-Settings)
1. Advanced Usage
  1. [Manually Specifying Settings Files](https://github.com/thekompanee/chamber/wiki/Manually-Specifying-Settings-Files)
  1. [Predicate Methods](https://github.com/thekompanee/chamber/wiki/Predicate-Methods)
  1. [ERB Preprocessing](https://github.com/thekompanee/chamber/wiki/ERB-Preprocessing)
  1. [Outputting Your Settings](https://github.com/thekompanee/chamber/wiki/Outputting-Your-Settings)
  1. [Basic Boolean Conversion](https://github.com/thekompanee/chamber/wiki/Basic-Boolean-Conversion)
  1. [Extending Chamber](https://github.com/thekompanee/chamber/wiki/Extending-Chamber)
  1. Namespaces
    1. [What Are They?](https://github.com/thekompanee/chamber/wiki/What-Are-Namespaces%3F)
    1. Strategies
      1. [File-Based](https://github.com/thekompanee/chamber/wiki/File-Based-Namespaces)
      1. [Inline](https://github.com/thekompanee/chamber/wiki/Inline-Namespaces)
      1. [Mix and Match](https://github.com/thekompanee/chamber/wiki/Mix-and-Match-Namespace-Strategies)
      1. [DRYing Up Shared Settings](https://github.com/thekompanee/chamber/wiki/DRYing-Up-Your-Shared-Settings)
      1. [Specifying Multiple Namespaces](https://github.com/thekompanee/chamber/wiki/Specifying-Multiple-Namespaces)
      1. [Handling Duplicates/Collisions](https://github.com/thekompanee/chamber/wiki/Handling-Duplicates-Collisions)
1. [Command Line Reference](https://github.com/thekompanee/chamber/wiki/Command-Line-Reference)
  1. Settings
    1. [show](https://github.com/thekompanee/chamber/wiki/CLI-show)
    1. [files](https://github.com/thekompanee/chamber/wiki/CLI-files)
    1. [secure](https://github.com/thekompanee/chamber/wiki/CLI-secure)
    1. [compare](https://github.com/thekompanee/chamber/wiki/CLI-compare)
    1. [init](https://github.com/thekompanee/chamber/wiki/CLI-init)
  1. [heroku](https://github.com/thekompanee/chamber/wiki/CLI-heroku)
    1. [push](https://github.com/thekompanee/chamber/wiki/CLI-heroku-push)
    1. [pull](https://github.com/thekompanee/chamber/wiki/CLI-heroku-pull)
    1. [diff](https://github.com/thekompanee/chamber/wiki/CLI-heroku-diff)
  1. travis
    1. [secure](https://github.com/thekompanee/chamber/wiki/CLI-travis-secure)

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
