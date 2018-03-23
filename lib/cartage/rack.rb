# frozen_string_literal: true

require 'pathname'
require 'json'

# Cartage, a package builder.
class Cartage
  # Generate and mount the full metadata reporter, Cartage::Rack.
  def self.Rack(root_path = nil, &filter)
    Cartage::Rack.send(:new, root_path, &filter)
  end

  # Cartage::Rack is a simple application that reads an application's static
  # release metadata and returns it as an (optionally filtered)
  # +application/json+ value, or as a +text/plain+ string if called with
  # +.text+ or +.txt+.
  class Rack
    VERSION = '2.2' #:nodoc:

    class << self
      # When +true+, Cartage::Rack and Cartage::Rack::Simple will raise an
      # exception if there is no metadata file (<tt>release-metadata.json</tt> or
      # +release_hashref+). May be explicitly turned off.
      #
      # Defaults to +true+ except in development or test environments (based on
      # <tt>$RAILS_ENV</tt>, <tt>$APP_ENV</tt> and <tt>$RACK_ENV</tt>).
      def require_metadata(value = (arg = false; nil)) # rubocop:disable Style/Semicolon
        @require_metadata = value unless arg == false
        @require_metadata || default_require_metadata
      end

      private

      def default_require_metadata
        environment = ENV['RAILS_ENV'] || ENV['APP_ENV'] || ENV['RACK_ENV'] || 'development'
        environment !~ /\A(?:development|test)\z/i
      end
    end

    def initialize(root_path = nil, &filter) # :nodoc:
      @metadata = Cartage::Rack::Metadata.new(root_path, filter: filter)
    end

    def call(env) #:nodoc:
      type, body = resolve_content(env)
      [ '200', { 'Content-Type' => type }, [ body ] ]
    end

    def inspect #:nodoc:
      "#{self.class} for #{@metadata.inspect}"
    end

    private

    def resolve_content(env)
      content = @metadata.resolve

      case env['PATH_INFO']
      when /\.te?xt\z/
        type = 'text/plain'
        body = [
          "name: #{dig(content, 'package', 'name')}",
          "environment: #{dig(content, 'env', 'name')}",
          "hashref: #{dig(content, 'package', 'hashref')}"
        ]

        value = dig(content, 'package', 'timestamp')
        body << "timestamp: #{value}" if value

        repo = dig(content, 'package', 'repo')
        body << "#{repo['type']}: #{repo['url']}" if repo
        body = body.join("\n")
      else
        type = 'application/json'
        body = content.to_json
      end

      [ type, body ]
    end

    attr_reader :metadata

    #:nocov:
    def dig(hash, key, *rest)
      if hash.respond_to?(:dig)
        hash.dig(key, *rest)
      else
        DIGGER.call(hash, key, *rest)
      end
    end

    DIGGER = ->(h, k, *r) { #:nodoc:
      v = h[k]
      if v.nil? || r.empty?
        v
      else
        DIGGER.call(v, *r)
      end
    }
    private_constant :DIGGER
    #:nocov:
  end
end

require_relative 'rack/simple'
require_relative 'rack/metadata'
