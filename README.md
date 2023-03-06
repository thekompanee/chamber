Chamber
================================================================================

<div align="center">
  <a href="https://rubygems.org/gems/chamber" alt="RubyGems Version">
    <img src="https://img.shields.io/gem/v/chamber.svg?style=flat-square&label=current-version" alt="RubyGems Version" />
  </a>

  <a href="https://rubygems.org/gems/chamber" alt="RubyGems Rank Overall">
    <img src="https://img.shields.io/gem/rt/chamber.svg?style=flat-square&label=total-rank" alt="RubyGems Rank Overall" />
  </a>

  <a href="https://rubygems.org/gems/chamber" alt="RubyGems Rank Daily">
    <img src="https://img.shields.io/gem/rd/chamber.svg?style=flat-square&label=daily-rank" alt="RubyGems Rank Daily" />
  </a>

  <a href="https://rubygems.org/gems/chamber" alt="RubyGems Downloads">
    <img src="https://img.shields.io/gem/dt/chamber.svg?style=flat-square&label=total-downloads" alt="RubyGems Downloads" />
  </a>

  <a href="https://github.com/thekompanee/chamber/actions?query=workflow%3ABuild" alt="Build Status">
    <img src="https://img.shields.io/github/workflow/status/thekompanee/chamber/Build?label=CI&style=flat-square&logo=github" alt="Build Status" />
  </a>

  <a href="#" alt="Maintainability">
    <img src="https://img.shields.io/codeclimate/maintainability/thekompanee/chamber?style=flat-square&label=grade" alt="Maintainability" />
  </a>
</div>

<br>

Chamber is the auto-encrypting, extremely organizable, Heroku-loving,
CLI-having, non-extra-repo-needing, non-Rails-specific-ing, CI-serving
configuration management library.

We looked at all of the options out there and thought something was still
missing, so we wrote Chamber.  We made it with lots of ❤ and we hope you like it
as much as we do.

What Sets Chamber Apart
--------------------------------------------------------------------------------

For an idea of how Chamber compares to other popular libraries, check out our
[Gem Comparison][comparison].

Basic Usage
--------------------------------------------------------------------------------

Before starting this guide, make sure you [install chamber][installation].

Once your app is initialized, you should have a `settings.yml` file somewhere.
A lot of times it's the root of your project and sometimes it's in a framework
specific location.

Inside of here you can define any settings you'd like like so:

```yaml
# settings.yml

smtp_username: 'my_username'
smtp_password: 'my_password'
```

From there you can access your settings by using the special `Chamber.dig`
constant.

```ruby
Chamber.dig('smtp_password')
# => 'my_password'
```

If you want to encrypt a setting, prefix the setting name with `_secure_` like
so:

```ruby
# settings.yml

smtp_username:         'my_username'
_secure_smtp_password: 'my_password'
```

And then run `chamber secure`.  Your settings file will have an encrypted value:

```ruby
# settings.yml

smtp_username:         'my_username'
_secure_smtp_password: JL5hAVux4tERpv49QPWxy9H0VC2Rnk7V8/e8+1XOwPcXcoH/a7Lh253UY/v9m8nI/Onb+ZG9nZ082J4M/BmLa+f7jwMEwufIqbUhUah9eKIW8xcxlppBYpl7JVGf2HJF5TfCN44gMQNgGNzboCQXKqRyeGFm4u772Sg9V2gEx/q7qJ6F4jg7v/cltCFLmJfXA2SHA5Dai4p9L4IvMVVJGm34k5j7KOegNqpVWs2RY99cagjPuzc9VM2XSUsXgqcUJdmH8YtPW8Kqkyg0oYlRh6VQWABlWXwTZz74QjTTjqtqfoELIoFTMBDh+cCvuUTAE5m06LhlqauVrB4UnBsd5g==
```

which you still access the same way because Chamber handles the decryption for
you:

```ruby
Chamber.dig('smtp_password')
# => 'my_password'
```

Full Reference
--------------------------------------------------------------------------------

There's so much to Chamber, we couldn't put it all in the README.  For the full
Chamber guide, visit the [wiki][wiki].

Credits
--------------------------------------------------------------------------------

Chamber was written by [Jeff Felchner][jeff-profile] and
[Mark McEahern][mark-profile]

![The Kompanee][kompanee-logo]

Chamber is maintained and funded by [The Kompanee, Ltd.][kompanee-site]

The names and logos for The Kompanee are trademarks of The Kompanee, Ltd.

License
--------------------------------------------------------------------------------

Chamber is Copyright © 2014-2023 Jeff Felchner and Mark McEahern. It is free
software, and may be redistributed under the terms specified in the
[LICENSE][license] file.

[comparison]:    https://github.com/thekompanee/chamber/wiki/Gem-Comparison
[jeff-profile]:  https://github.com/jfelchner
[kompanee-logo]: https://kompanee-public-assets.s3.amazonaws.com/readmes/kompanee-horizontal-black.png
[kompanee-site]: http://www.thekompanee.com
[license]:       https://github.com/thekompanee/chamber/blob/master/LICENSE.txt
[mark-profile]:  https://github.com/m5rk
[wiki]:          https://github.com/thekompanee/chamber/wiki
[installation]:  https://github.com/thekompanee/chamber/wiki/Installation
