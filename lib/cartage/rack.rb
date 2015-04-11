require 'pathname'
require 'json'

# Cartage, a package builder.
class Cartage; end

# Cartage::Rack is a simple application that reads an application’s
# +release_hashref+ and returns it as a +text/plain+ string, or as
# +application/json+ if it is called with +.json+.
#
# If +release_hashref+ does not exist, Cartage::Rack will read the hash of the
# current HEAD.
class Cartage::Rack
  VERSION = '1.1' #:nodoc:

  # Creates a new version of the Cartage::Rack application to the specified
  # +root_path+, or +Dir.pwd+.
  def self.mount(root_path = nil)
    new(root_path || Dir.pwd)
  end

  # Sets the root path for Cartage::Rack.
  def initialize(root_path)
    @root_path = Pathname(root_path)
  end

  # The Rack application method.
  def call(env)
    content = {
      env:             application_env,
      release_hashref: release_hashref,
      timestamp:       timestamp
    }.delete_if(&->(_, v) { v.nil? })

    case env['PATH_INFO']
    when /\.json\z/
      type = 'application/json'
      body = content.to_json
    else
      type = 'text/plain'
      body = "#{content[:env]}: #{content[:release_hashref]}"
      body += " (#{content[:timestamp]})" if content[:timestamp]
    end

    [ '200', { 'Content-Type' => type }, [ body ] ]
  end

  def inspect
    %Q(#{self.class} for #{@root_path.expand_path.basename})
  end

  private
  def application_env
    ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'UNKNOWN'
  end

  def release_hashref
    file = @root_path.join('release_hashref')
    if file.exist?
      file.read.split($/).first.chomp
    elsif @root_path.join('.git').directory?
      "(git) #{%x(git rev-parse --abbrev-ref HEAD).chomp}"
    else
      'UNKNOWN - no release_hashref or .git directory'
    end
  end

  def timestamp
    file = @root_path.join('release_hashref')
    if file.exist?
      stamp = file.read.split($/, 2)[1]
      stamp = nil if stamp && stamp.empty?
      stamp.chomp if stamp
    end
  end
end
