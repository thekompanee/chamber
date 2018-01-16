Version v2.12.0 - January 15, 2018
================================================================================

Add
--------------------------------------------------------------------------------
  * Ability to parse ISO8601 formatted environment variables
  * chamber sign --verify
  * File#verify
  * Files::Signature#verify
  * chamber sign
  * Ability for Instance to sign its files
  * Ability for FileSet to sign all of its Files
  * Ability for File to create a signature for itself
  * Files::Signature
  * Ability for initialization to create signature key
  * Generic local settings to gitignore
  * Sinatra/Padrino integration

Change
--------------------------------------------------------------------------------
  * Key::Base to always return the signature key if it exists
  * Move base64 requires to the correct files
  * Simplify condition in chamber secure
  * Simplify gitignore additions
  * Message formatting for initialization
  * Initialization to create passphrase files
  * initialization output to only show namespaces hint selectively
  * Rails integration location

Fix
--------------------------------------------------------------------------------
  * Public keys being incorrectly gitignored
  * Asking to overwrite settings files on re-initialization

Version v2.11.0 - January 12, 2018
================================================================================

Add
--------------------------------------------------------------------------------
  * on/off and 1/0 to boolean conversion
  * Ability for EncryptionFilter to handle namespaced keys
  * Keys::Base that other key classes inherit from
  * EncryptionKey
  * namespaced key detection to DecryptionKey
  * Ability to generate multiple key pairs via init
  * Ability to automatically convert ENV nils
  * Ability to automatically convert ENV arrays
  * Ability to automatically convert ENV booleans
  * Ability to automatically convert ENV floats
  * Ability to automatically convert ENV integers

Change
--------------------------------------------------------------------------------
  * DecryptionFilter to attempt multiple keys
  * EncryptionFilter.execute to use each_with_object
  * EncryptionFilter to allow multiple encryption keys to be passed
  * Runner to allow multiple keys to be specified
  * DecryptionFilter to attempt multiple decryption keys
  * Singularize decryption_keys variable
  * key options to be able to be a hash
  * Key so namespace detection only works with standard key names
  * Configuration to force options to have been set
  * default public key hash key due to Hashie conflict
  * Key to always include the default key file path
  * Fail silently if Key is not found
  * Rename Key classes
  * Rename all variables from singular 'key' to 'keys'
  * Simplify the ContextResolver
  * Consolidate definitions of the secure token

Fix
--------------------------------------------------------------------------------
  * Hashie::Mash not handling converting nested hash keys to symbols
  * SecureRandom not being defined

Remove
--------------------------------------------------------------------------------
  * Unneeded require statments
  * BooleanConversionFilter
  * Environmentable module and inline its single usage

Version v2.10.2 - December 29, 2017
================================================================================

Fix
--------------------------------------------------------------------------------
  * Warning being thrown when secured value is nil

Version v2.10.1 - February 9, 2017
================================================================================

Fix
--------------------------------------------------------------------------------
  * Thor throwing warnings about --shell option
  * chamber showing it's going to encrypt when it's not

Version v2.10.0 - February 4, 2017
================================================================================

Change
--------------------------------------------------------------------------------
  * from deprecated OpenSSL::Cipher::Cipher

Add
--------------------------------------------------------------------------------
  * Chamber types
  * base 'encrypt' and 'decrypt' methods to Chamber

Fix
--------------------------------------------------------------------------------
  * Issue with large values being re-encrypted

Version v2.9.1 - August 23, 2016
================================================================================

  * Config variables are shell escaped for heroku push

Version v2.9.0 - May 12, 2016
================================================================================

Fixed
--------------------------------------------------------------------------------
  * YAML multiline strings not being secured properly

Changed
--------------------------------------------------------------------------------
  * Generalize the encryption and decryption filters
  * Extract more encryption method logic
  * Extract encryption method into a method
  * Extract public key encryption to EncryptionMethods::PublicKey
  * Extract SSL encryption into EncryptionMethods::Ssl
  * Extract decryption method into its own method
  * Move decryption methods into their own classes
  * LARGEDATA to LARGE_DATA

Removed
--------------------------------------------------------------------------------
  * Unneeded method

Uncategorized
--------------------------------------------------------------------------------
  * Encryption of large data with test cases

Version v2.8.0 - March 24, 2015
================================================================================

Added
--------------------------------------------------------------------------------
  * Support for rails engine projects
  * Create the .gitignore file if it doesn't exist
  * newlines to .chamber lines inserted in the .gitignore file
  * templates directory to the gemspec
  * circle.yml
  * rubygems config

Fixed
--------------------------------------------------------------------------------
  * Lines in output which were not colored
  * Pathname implicit conversion to string in Ruby 2.2.1

Uncategorized
--------------------------------------------------------------------------------
  * Add names and dates
  * Swap logo
  * Add credits and license info to README

Version v2.7.1 - October 30, 2014
================================================================================

Bugfix
--------------------------------------------------------------------------------
  * Settings overridden by environment variables were decrypted

Version v2.7.0 - October 30, 2014
================================================================================

Feature
--------------------------------------------------------------------------------
  * Add key and encrypted value to failed decryption error message

Version v2.6.0 - October 30, 2014
================================================================================

Feature
--------------------------------------------------------------------------------
  * Allow the chamber decryption key to be pulled from CHAMBER_KEY
  * Change 'show --only-secure' to '--only-sensitive'

Version v2.5.0 - October 30, 2014
================================================================================

Feature
--------------------------------------------------------------------------------
  * Allow any values (including complex ones) to be secured
  * Add a protected emailable private key when initializing
  * Allow Chamber to find '*.yml.erb' files as well
  * Add the FailedDecryptionFilter to the pipeline
  * Add FailedDecryptionFilter
  * Don't show the decrypted setting when pushing to Heroku
  * Add --only-secure option to 'show'
  * Allow host settings to override environment settings in Rails

Uncategorized
--------------------------------------------------------------------------------
  * Update README.md
  * Update README.md
  * Update README.md
  * Update README.md

Bugfix
--------------------------------------------------------------------------------
  * Fix gemspec binary filter

Version v2.4.0 - September 23, 2014
================================================================================

  * Allow hashie to be upgraded to 3.x

Version v2.3.2 - August 8, 2014
================================================================================

Uncategorized
--------------------------------------------------------------------------------
  * Ensure Chamber loads Chamber::Instance in bin/chamber
  * Fix README typos
  * Add `chamber secure` example usage to README

Bugfix
--------------------------------------------------------------------------------
  * Special Regex characters caused values to not encrypt
  * Add a missing 'require' for configuration
  * Add missing 'pathname' requires to files that use it

Version v2.3.1 - July 10, 2014
================================================================================

  * made fix available for binary as well
  * specified rubinius version
  * quick fix until rubysl gets updated

Version v2.3.0 - June 29, 2014
================================================================================

Feature
--------------------------------------------------------------------------------
  * When securing files, do not rewrite the entire file
  * Add 'to_flattened_name_hash' to Settings
  * Allow Settings to filter only those which are insecure
  * Add InsecureFilter
  * Add a filter for translating secure keys

Bugfix
--------------------------------------------------------------------------------
  * When running 'chamber secure' only display insecure settings

Uncategorized
--------------------------------------------------------------------------------
  * Fix BooleanConversionFilter bug when nil value at top level
  * added rubinius to travis ci
  * update thor
  * fixed decryption hint description
  * glob fix for rubinius
  * Lock Hashie to 2.0.5 as 2.1 has a bug that breaks the build
  * On Ruby 1.9.x, the Pathname must be converted over to a string before
    Shellwords can escape it
  * Having issues with the bundler cache soooo, let's try removing it.

Version v2.2.1 - April 6, 2014
================================================================================

  * Expose dry-run to 'chamber secure'

Version v2.2.0 - April 6, 2014
================================================================================

  * Make 'chamber secure' give output progress on what it's doing
  * Update README
  * Add code coverage badge
  * Add codeclimate test coverage reporting
  * Fix badges
  * Add Ruby 2.1.1 to Travis build
  * Add Bundler cache to Travis

Version v2.1.9 - April 5, 2014
================================================================================

  * Allow the context resolver to accept hashes which have stringified keys but
    still do the correct thing

Version v2.1.8 - January 27, 2014
================================================================================

  * Fix the template so that both examples do not point to the same setting

Version v2.1.7 - January 27, 2014
================================================================================

  * The gemspec needed to have the template files included in the file list

Version v2.1.6 - January 27, 2014
================================================================================

  * Revert filepath changes. Abandon Thor copy method and use FileUtils instead.
    :angry:

Version v2.1.5 - January 27, 2014
================================================================================

  * Thor is doing some really weird stuff with the load path which works locally
    but not when deployed

Version v2.1.4 - January 27, 2014
================================================================================

  * Fix some filepath issues with the chamber initializer

Version v2.1.3 - January 19, 2014
================================================================================

  * Make sure that chamber doesn't count non-namespaced files as namespaced if
    the full path happens to have a dash in it

Version v2.1.2 - January 16, 2014
================================================================================

  * Fix failing spec when directory didn't exist before spec was run
  * Fix method_missing issue

Version v2.1.1 - January 16, 2014
================================================================================

  * Raising an error when a value cannot be decrypted is unacceptable when
    deploying to Heroku where a private key may not exist, but an environment
    variable does

Version v2.1.0 - January 15, 2014
================================================================================

  * *Always* use the ContextResolver when loading options
  * Move Moses

Version v2.0.0 - January 15, 2014
================================================================================

  * Make sure that the basepath defaults to the rootpath if none is explicitly
    set
  * Update README for v2.0.0
  * Massive refactor of the chamber binary to be more organized and DRYer.
  * Update method_missing on the Instance and Chamber so that things are
    properly delegated
  * Allow Settings to be able to filter only those settings which have been
    marked as "secure"
  * Refactor Settings#secure to flip the script on the merging of metadata
  * Add a SecureFilter for extracting only items marked as 'secure' from a
    Settings instance
  * Extract all command stuff out into a separate file
  * Update WARNING messages to use `Kernel.warn`
  * Ruby 1.9.2 does not have a `.write` method on `IO`
  * Update to the proper pessimistic version lock for simplecov
  * Expose the Chamber#files
  * Add a 'secure' task to the CLI which secures all the files that Chamber
    knows about
  * Add the notion of a 'rootpath' to the CLI
  * Update the encryption/decryption filters so that they can handle nil values
    (or any values which do not respond to `#match`)
  * Pass the encryption key to the Chamber loader
  * Add note to the README about using `chamber settings init`
  * Remove items from the README which I'm not implementing right now
  * Add the ability for FileSets to secure their Files
  * Update FileSet so that it can have the encryption/decryption keys passed in
    and then passed to the Files
  * Allow Files to be able to secure their contents
  * Allow File to have the encryption/decryption keys passed in
  * Allow decryption_key and encryption_key to be passed via the command line
  * Add `chamber settings init` to create the keypair and add the private key to
    the gitignore file
  * Allow Settings to be able to encrypt any secure settings it may be holding
  * Pass all options to clean_settings so that we don't need to update every
    time we add new settings
  * Extract Settings metadata out into a new method
  * Update some initializers from using `#fetch` to `#[]` because we never want
    them to be nil even if they key exists
  * Add encryption_key to the Configuration
  * Add EncryptionFilter
  * Change our convention in the README from 'x_foo_x' to '_secure_foo'
  * Add an appropriate image to the README
  * Change description of the app in the README
  * Fix list numbering in the README
  * Simplify the creation of settings from a FileSet and keep the namespace
    logic from leaking out of the initializer
  * Introduce the Instance which encapsulates the Configuration and the FileSet
  * Convert Chamber from a class to a module
  * Extract instance information for Chamber into Chamber::Configuration
  * Tweak visibility of Chamber attribute methods
  * Remove unneeded method
  * Allow decryption keys o be passed in
  * Split Settings filters between prefilters (which happen as soon as data is
    written) and post filters (which happen once data is read)
  * Update Settings#merge! to #merge and have it always return a new Settings
    object
  * fixup! 679bb861166dbe74dd33c293258425b662663ee7
  * Add documentation to Settings#eql?
  * Add == to Settings so that we can verify that it is equal to other hash-like
    objects
  * Make sure that we don't deeply nest NamespaceSets if we create a
    NamespaceSet from a NamespaceSet
  * Tweak Settings#to_hash to make sure we're getting a duplicated Hash (and not
    a Hashie::Mash)
  * Now that NamespaceSets are smarter, we can remove some unneeded dependencies
    from Settings and simplify the specs
  * We don't need the additional 'Chamber' namespace
  * #to_a not #to_ary
  * Lazily process namespaces in a NamespaceSet so that we refrain from doing
    processing until we actually need to access the values
  * Allow NamespaceSets to be created from single values
  * Ensure a NamespaceSet can be created from another NamespaceSet
  * Use our new sweet square bracket NamespaceSet creation in the specs
  * Allow NamespaceSets to create themselves from a set of values
  * Fix documentation typo
  * Always duplicate the settings hash before returning it so that we don't have
    inadvertent modifications
  * Add the new DecryptionFilter to Settings
  * Add a DecryptionFilter
  * Delete now unused code from SystemEnvironment
  * Use the new filters in Settings
  * Use the new Environmentable module in SystemEnvironment
  * Add NamespaceFilter
  * Add an EnvironmentFilter
  * Add a BooleanConversionFilter
  * Make NamespaceSet always store namespaces as Strings to make checking for
    equality easier
  * Add note to the README about the CLI interface for encryption/decryption
  * Proposed README updates

Version v1.0.3 - January 6, 2014
================================================================================

  * The heroku diff command needed to take ignored files into account as well to
    stop from giving false positives

Version v1.0.2 - January 6, 2014
================================================================================

  * Loading 'environment' wasn't executing the proper initializer hook that the
    Chamber Railtie needed, loading 'application' works

Version v1.0.1 - January 5, 2014
================================================================================

  * Fix the 'heroku pull' command not displaying variables

Version v1.0.0 - January 5, 2014
================================================================================

  * Manually sort the globbed files. It appears that having them be returned
    alphabetically is system-dependent
  * Fix an issue where, if Chamber had not yet been loaded, a bunch of methods
    would throw errors
  * Update the .travis.yml file to include 2.1.0 and not to require rake
  * Remove all the rake task stuff and instead use Thor tasks for working with
    settings
  * Case change in specs to better resemble what will actually be returned by
    SystemEnvironment.extract_from
  * Allow Chamber to convert its settings into a string
  * Add note to the README about best practices for gitignore exclusions
  * ERB needs to be required. Missed this
  * Allow Chamber.to_hash to return the settings hash
  * Add Thor
  * Fix README typo
  * Allow settings files to (optionally) be explicitly passed into the loader
  * When converting a Settings object to environment variables, sort them by
    their key so they are easier to parse
  * Expose FileSet#filenames via the base Chamber class
  * Add FileSet#filenames which returns a list of file path strings representing
    the ordered list of settings files which were processed
  * Add documentation for FileSet#to_settings
  * Add note to the README about how Chamber converts boolean-like values
  * Reorder section in the README
  * Add dotenv to the alternatives list in the README
  * Fix the name of the Heroku rake task in the README
  * Add note about ERB preprocessing to the README
  * Add info to the README about the predicate methods exposed via Hashie
  * Fix an issue where a previous glob's files was being loaded after a
    subsequent glob's files
  * Get to 100% test coverage on Chamber
  * Rework the HerokuConfiguration class so that we can get 100% test coverage
    on it
  * Add documentation and specs for the Settings class
  * Refactor Settings a bit to make `#data=` a bit more readable
  * Fix and update README for 1.0
  * Update the gemspec with some additional options and small changes (including
    adding me to the authors)
  * Add documentation and specs for the FileSet class
  * Change the directory that the main chamber spec file stores its temp files
    in
  * Add documentation and specs for the SystemEnvironment class
  * Add documentation and specs for the NamespaceSet class
  * Add documentation and specs for the File class
  * Nice big refactoring moving from procedural to object-oriented
  * Convert boolean-like values to actual booleans so that we can use them
    properly on Heroku
  * Allow settings files to contain namespaces
  * When loading via Rails, go ahead and automatically add a namespace for the
    Rails environment
  * Change from using subclasses for namespaces and instead pass them into the
    load function as pairs of names/callables
  * Pass namespaces through to the load_directory method
  * Add a Rails file to do Rails-y stuff
  * Rename Chamber to Chamber::Base so that we can make chamber.rb a bit more
    readable regarding requires
  * Allow settings files to be loaded even if only a namespaced set of files
    exists.
  * Allow credentials to be loaded prior to other settings so that they may be
    used (via ERB) in settings
  * Upgrade rspectacular so that it works with SimpleCov out of the box
  * Update badges to use m5rk instead of stevenhallen
  * Extracing multiple blocks out of the environment methods
  * Pull common environment functionality into a with_environment method and
    yield to do the processing which is different
  * Make both the 'to_environment' method and 'with_existing_environment' method
    as similar as possible so that we can better see the duplication
  * Add additional methods to delegate to the instance (for convenience)
  * Add a Railtie which loads Chamber with the proper Rails config path and load
    the rake task
  * Add a Heroku rake file which can push the settings associated with Chamber
    to a Heroku app
  * Allow Chamber to be able to export a hash of environment variables
  * Use latest ruby in .ruby-version
  * Allow Chamber to load not only ALL YAML files from the settings directory,
    but also those which match the specified namespaces
  * Refactor where the globbing is when loading files. We may want to let the
    user specify the directory, but no the glob
  * Allow settings to be loaded from a 'settings' subdirectory, but only if they
    are not namespaced
  * Extract settings processing out into a separate method
  * Sanity spec to make sure the merge that happens is a deep merge
  * When working with namespaced files, if one of them doesn't exist, do not
    raise an exception
  * Make sure to reset the singletons after every spec
  * Forgot to make sure that if a method does not exist on settings, it should
    still raise a NoMethodError
  * Refactoring namespace loading. Let it be called multiple times, just check
    for unique values only
  * Make sure settings are cleared every time they are loaded
  * Make the settings accessor public
  * If the namespaces DSL is called multiple times, it clears the namespaces
    each time
  * Add the ability to load files based on namespaces
  * Allow the environment to override values in the settings files
  * Allow settings to contain ERB so that they can contain dynamic elements
  * Allow the instance to be accessed via 'env'
  * Settings may be accessed through object-like notation
  * Decompress a few lines for better readability
  * Use method missing to delegate any message sent to Chamber as a message for
    the underlying Hash
  * Remove unused core extensions
  * Switch to Hashie::Mashes to get the object-like accessing as well as
    indifferent key access
  * Allow settings to be accessed through Hash-like syntaxe
  * Add core extensions for a couple Hash methods so we don't have to include an
    external library
  * Delegate all methods to the instance
  * Chamber loads the settings.yml file from the base path by default
  * Chamber can load itself from any path that's passed in to it
  * Remove the spec_helper since rspectacular does everything for us
  * Install rspectacular as a development dependency
  * Remove bundler from the development dependencies. It lives outside of
    gemspecs
  * More README Changes
  * Proposed Changes to Chamber API
  * Fix spacing for chamber.yml example
  * Add more descriptive info to chamber.yml example
  * Fix badge
  * Add Code Climate badge

Version v0.0.4 - November 19, 2013
================================================================================

  * Bump to 0.0.4
  * Update README to remove reference to Settings.instance
  * Use method_missing to avoid need to specify Settings.instance

Version v0.0.3 - November 19, 2013
================================================================================

  * Bump to 0.0.3
  * Alias :env to :instance
  * Add note re: load! to README
  * Fix unbalanced parens in README

Version v0.0.2 - November 14, 2013
================================================================================

  * Bump to 0.0.2
  * Continue tweaking README
  * More tweaks to README
  * Fix README
  * Add content to README
  * Tweak README
  * Fix link to travis status image
  * Add .png to status image
  * Add build status to github
  * Drop 1.8.7
  * Add travis configuration
  * Make rspec spec the default rake task
  * RSpec configuration for filtering
  * Finish first round of implementation/testing
  * Expect specific error
  * Adding tests
  * Sort requires
  * Add runtime dependency on hashie
  * Keep a list of sources
  * Ruby project files
  * Primitive test
  * First cut at implementing Chamber.source
  * Update README
  * Update README with description
  * Initial spec_helper.rb
  * Add rspec and simplecov
  * Update gemspec
  * bundle gem chamber

