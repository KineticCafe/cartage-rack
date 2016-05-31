# frozen_string_literal: true

require 'pathname'
require 'json'

##
# A representation for Cartage metadata for use with Cartage::Rack and
# Cartage::Rack::Simple.
class Cartage::Rack::Metadata
  METADATA_CLEANER = ->(_, v) { #:nodoc:
    v.delete_if(&METADATA_CLEANER) if v.kind_of?(Hash)
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  }
  private_constant :METADATA_CLEANER

  # Parse static release metadata from the +root_path+ (or <tt>Dir.pwd</tt>)
  # and prepare the Metadata object for resolution.
  #
  # If +filter+ is provided, it should be a callable (a lambda or proc) that
  # will manipulate the content on resolution.
  #
  # If +required+ is +true+ (defaults to the value of
  # Cartage::Rack.require_metadata, which is +true+ for everything except
  # +development+ and +test+), then a RuntimeError will be thrown if there is
  # no static release metadata.
  #
  # If +required+ is +false+, then the release metadata can be loaded from the
  # active environment.
  def initialize(root_path = nil, required: Cartage::Rack.require_metadata, filter: nil)
    @root_path = Pathname(root_path || Dir.pwd)
    @filter = filter
    @content = read_release_metadata_json || read_release_hashref

    fail 'Cannot find release-metadata.json or release_hashref' if required && !@content

    @source ||= :live
  end

  # Resolve the metadata content with the application environment. If a
  # +filter+ was provided on object construction, apply it do the merged
  # content data.
  def resolve
    content.merge(application_env).tap do |data|
      @filter.call(data) if @filter
    end.delete_if(&METADATA_CLEANER)
  end

  def inspect #:nodoc:
    "#{@root_path.expand_path.basename} (#{@source})"
  end

  private

  def application_env
    @application_env ||= {
      'env' => { 'name' => ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'UNKNOWN' }
    }
  end

  def content
    return @content if @content

    {
      'package' => {}
    }.tap do |result|
      package = result['package']
      package['name'] = @root_path.basename.to_s
      package['hashref'] = release_hashref
      package['timestamp'] = Time.now.utc.strftime('%Y%m%d%H%M%S')

      if repo?
        package['repo'] = {
          'type' => 'git', # Hardcoded until we have other support
          'url' => repo_url
        }
      end
    end
  end

  def read_release_metadata_json
    file = @root_path.join('release-metadata.json')

    return unless file.exist?

    @source = :release_metadata_json
    JSON.parse(file.read)
  end

  def read_release_hashref
    file = @root_path.join('release_hashref')

    return unless file.exist?

    @source = :release_hashref

    hashref, timestamp, = file.read.split($/)

    {
      'package' => {
        'name' => @root_path.basename.to_s,
        'hashref' => hashref,
        'timestamp' => timestamp
      }
    }.delete_if(&METADATA_CLEANER)
  end

  def repo_url
    return unless repo?
    unless defined?(@repo_url)
      @repo_url = %x(git remote show -n origin).
        match(/\n\s+Fetch URL: (?<fetch>[^\n]+)/)[:fetch]
    end
    @repo_url
  end

  def release_hashref
    if repo?
      "(git) #{%x(git rev-parse --abbrev-ref HEAD).chomp}"
    else
      'UNKNOWN - no .git directory'
    end
  end

  def repo?
    @is_repo = @root_path.join('.git').directory? unless defined?(@is_repo)
    @is_repo
  end
end
