require 'pathname'
require 'json'

# Cartage, a package builder.
class Cartage; end

# Cartage::RackChangelog is a simple application that reads an application’s
# +release_changelog+ and returns it as an a array, or as
# +application/json+ if it is called with +.json+.
#
# If +release_changelog+ does not exist, Cartage::RacChangelog will read the hash of the
# current HEAD.
class Cartage::RackChangelog
  # Creates a new version of the Cartage::RackChangelog application to the specified
  # +root_path+, or +Dir.pwd+.
  def self.mount(root_path = nil)
    new(root_path || Dir.pwd)
  end

  # Sets the root path for Cartage::RackChangelog.
  def initialize(root_path)
    @root_path = Pathname(root_path)
  end

  # The Rack application method.
  def call(env)
    content = {
      changelog:       read_changelog,
    }.delete_if(&->(_, v) { v.nil? })

    case env['PATH_INFO']
    when /\.json\z/
      type = 'application/json'
      body = [ content.to_json ]
    else
      type = 'text/plain'
      body = content[:changelog]
    end

    [ '200', { 'Content-Type' => type }, body ]
  end

  def inspect
    %Q(#{self.class} for #{@root_path.expand_path.basename})
  end

  private

  def read_changelog
    file = @root_path.join('release_changelog')
    file.exist? ? file.readlines : "File doesn't exist"
  end

end
