# frozen_string_literal: true

# NOTE: This file is not the canonical source of dependencies. Edit the
# Rakefile, instead.

source "https://rubygems.org/"

# Specify your gem's dependencies in cartage-rack.gemspec
gemspec

if ENV["LOCAL_DEV"]
  group :local_development, :test do
    gem "byebug", platforms: :mri
    gem "pry"
  end
end
