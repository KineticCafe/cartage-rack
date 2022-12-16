# Change History

## 2.3 / 2022-12-16

This is primarily a (mostly-mechanical) modernization of the codebase,
bringing it up to Kinetic Commerce 2022 standards.

- Remove dead development files: `.autotest`, `.gemtest`, `.minitest.rb`,
  `.rubocop.yml`, `.simplecov-prelude.rb`, `.travis.yml`

- Add new development files: `.github/workflows/ruby.yml`, `.rdoc_options`,
  `.standard.yml`, `Appraisals`, `gemfiles/*.gemfile`

- Clean up configuration: `.gitignore`, `.hoerc`, `Rakefile`

- Updated generated files: `Manifest.txt`, `cartage-rack.gemspec`

- Renamed `test/minitest_config.rb` to `test/minitest_helper.rb` to reflect
  consistent naming.

- Removed `context` alias for `describe`.

- Apply formatting from `standardrb` after dropping raw rubocop.

- Sunset cartage-rack as of this version.

## 2.2 / 2018-03-23

- Add support for ENV['APP_ENV'] per Sinatra documentation recommendations.

## 2.1 / 2016-06-28

- Fix default env issue where ENV['RAILS_ENV'] nor ENV['RACK_ENV'] is set
  by adding default string.

## 2.0 / 2016-05-31

- Rewrote for compatibility with cartage 2.0.

  - Renamed Cartage::Rack to Cartage::Rack::Simple and created a _new_
    Cartage::Rack that returns more information.

  - Extracted metadata gathering out of Cartage::Rack and into
    Cartage::Rack::Metadata.

  - Deprecated Cartage::Rack.mount in favour of Cartage::Rack() and
    Cartage::Rack::Simple() methods.

- 1 governance change

  - cartage-rack is now under the Kinetic Cafe Open Source [Code of
    Conduct][kccoc].

## 1.1 / 2015-04-11

- 2 minor enhancements

  - Implemented Cartage::Rack#inspect to prevent `rake routes` from
    presenting badly.

  - Preparing for a future Cartage change to the contents of the
    `release_hashref` file. The future `release_hashref` will be two lines:

        hashref
        timestamp

    If `release_hashref` has two lines, the timestamp will be included in
    the response. A timestamp will not be included if there is no
    `release_hashref` file.

- 1 development change

  - Implemented tests for Cartage::Rack.

## 1.0 / 2015-03-20

- 1 major enhancement

  - Birthday!

[kccoc]: https://github.com/KineticCafe/code-of-conduct
