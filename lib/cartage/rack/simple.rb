# frozen_string_literal: true

##
class Cartage::Rack
  class << self
    # Creates a new instance of the Cartage::Rack::Simple application to the
    # specified +root_path+, or +Dir.pwd+. This method has been deprecated.
    def mount(root_path = nil)
      warn <<~WARNING
        Cartage::Rack.mount(path) is deprecated; use Cartage::Rack::Simple(path) instead.
      WARNING
      Simple(root_path)
    end

    # Generate and mount the simple metadata reporter, Cartage::Rack::Simple,
    # for the application at +root_path+ or +Dir.pwd+.
    def Simple(root_path = nil)
      Cartage::Rack::Simple.new(root_path)
    end
  end

  # Cartage::Rack::Simple is a simple application that reads an application's
  # static release metadata and returns it as a +text/plain+ string, or as
  # +application/json+ if it is called with +.json+.
  #
  # If static release metadata does not exist and the application is in
  # +development+ or +test+ modes, Cartage::Rack::Simple will read data from
  # the operating environment.
  #
  # See Cartage::Rack::Metadata for more information.
  class Simple < Cartage::Rack
    private

    def resolve_content(env)
      full_content = @metadata.resolve

      content = {}

      content[:env] = dig(full_content, "env", "name")
      content[:release_hashref] = dig(full_content, "package", "hashref")
      content[:timestamp] = dig(full_content, "package", "timestamp")

      case env["PATH_INFO"]
      when /\.json\z/
        type = "application/json"
        body = content.to_json
      else
        type = "text/plain"
        body = "#{content[:env]}: #{content[:release_hashref]}"
        body += " (#{content[:timestamp]})" if content[:timestamp]
      end

      [type, body]
    end
  end
end
