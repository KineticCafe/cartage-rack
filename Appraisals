# frozen_string_literal: true

appraise "rack-1" do
  gem "rack", "~> 1.6"
  gem "rack-test", "~> 1.0"
end

appraise "rack-2" do
  gem "rack", "~> 2.0"
  gem "rack-test", "~> 1.0"
end

appraise "rack-3" do
  gem "rack", "~> 3.0"
end

# As of 2022-12-15, Psych 5.0 does not install on macOS Ventura. Lock to the
# latest known working version.
#
# Although Appraisal is supposed to have `#install_if` support for when it
# parses the Gemfile, it isn’t working, so we are using this workaround:
# https://github.com/thoughtbot/appraisal/issues/131#issuecomment-511075918
if RUBY_PLATFORM.match?(/darwin/)
  each do |spec|
    spec.gem "psych", "~> 4.0"
  end
end
