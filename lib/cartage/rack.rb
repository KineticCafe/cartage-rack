require 'pathname'

# Cartage, a package builder.
class Cartage; end

# Cartage::Rack is a simple application that reads an application’s
# +release_hashref+ and returns it as a +text/plain+ string, or as
# +application/json+ if it is called with +.json+.
#
# If +release_hashref+ does not exist, Cartage::Rack will read the hash of the
# current HEAD.
class Cartage::Rack
  VERSION = '1.0' #:nodoc:

  # Creates a new version of the Cartage::Rack application to the specified
  # +root_path+, or +Dir.pwd+.
  def self.mount(root_path = Dir.pwd)
    new(root_path)
  end

  # Sets the root path for Cartage::Rack.
  def initialize(root_path)
    @root_path = Pathname(root_path)
  end

  # The Rack application method.
  def call(env)
    file = @root_path.join('release_hashref')
    release_hashref = if file.exist?
                        file.read
                      elsif @root_path.join('.git').directory?
                        "(git) #{%x(git rev-parse --abbrev-ref HEAD)}"
                      else
                        'UNKNOWN - no release_hashref or source control directory'
                      end
    application_env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'UNKNOWN'

    case env['PATH_INFO']
    when /\.json\z/
      type = 'application/json'
      body = {
        env: application_env,
        release_hashref: release_hashref
      }.to_json
    else
      type = 'text/plain'
      body = "#{application_env}: #{release_hashref}"
    end

    [ '200', { 'Content-Type' => type }, [ body ] ]
  end
end
