# frozen_string_literal: true

require "minitest_helper"

describe Cartage::Rack::Simple do
  include Rack::Test::Methods

  let(:app) { Cartage::Rack::Simple(path) }
  let(:path) { "test/hillvalley" }
  let(:metadata) {
    {
      "env" => {"name" => "production"},
      "package" => {
        "name" => "hillvalley",
        "repo" => {
          "type" => "git",
          "url" => "git:doc@hillvalley.com/delorean.git"
        },
        "hashref" => "d0cb1ff",
        "timestamp" => "19851027104200"
      }
    }
  }

  def around(&block)
    stub_dir_pwd path do
      instance_stub Pathname, :exist?, true do
        instance_stub Pathname, :read, -> { metadata.to_json } do
          super(&block)
        end
      end
    end
  end

  it "warns when Cartage::Rack.mount(path) is used" do
    $VERBOSE, verbose = false, $VERBOSE
    assert_output nil, /Cartage::Rack.mount\(path\) is deprecated/ do
      Cartage::Rack.mount
      $VERBOSE = verbose
    end
  end

  it "inspects nicely for `rake routes` in Rails" do
    assert_equal "Cartage::Rack::Simple for hillvalley (release_metadata_json)",
      Cartage::Rack::Simple().inspect
  end

  it "returns text/plain content by default" do
    get "/"
    assert_equal "text/plain", last_response.headers["Content-Type"]
  end

  it "returns application/json content when requested" do
    get "/.json"
    assert_equal "application/json", last_response.headers["Content-Type"]
  end

  describe "application environment" do
    it "uses $RAILS_ENV first" do
      stub_env "RAILS_ENV" => "vne_sliar",
        "APP_ENV"   => "vne_ppa",
        "RACK_ENV"  => "vne_kcar" do
        get "/"

        assert last_response.ok?
        assert_equal "vne_sliar: d0cb1ff (19851027104200)", last_response.body
        assert_equal "text/plain", last_response.headers["Content-Type"]
      end
    end

    it "uses $APP_ENV second" do
      stub_env "RAILS_ENV" => nil, "APP_ENV" => "vne_ppa", "RACK_ENV" => "vne_kcar" do
        get "/"

        assert last_response.ok?
        assert_equal "vne_ppa: d0cb1ff (19851027104200)", last_response.body
        assert_equal "text/plain", last_response.headers["Content-Type"]
      end
    end

    it "uses $RACK_ENV third" do
      stub_env "RAILS_ENV" => nil, "APP_ENV" => nil, "RACK_ENV" => "vne_kcar" do
        get "/"

        assert last_response.ok?
        assert_equal "vne_kcar: d0cb1ff (19851027104200)", last_response.body
        assert_equal "text/plain", last_response.headers["Content-Type"]
      end
    end

    it "falls through to UNKNOWN without either $RAILS_ENV, $APP_ENV or $RACK_ENV" do
      stub_env "RAILS_ENV" => nil, "APP_ENV" => nil, "RACK_ENV" => nil do
        get "/"

        assert last_response.ok?
        assert_equal "UNKNOWN: d0cb1ff (19851027104200)", last_response.body
        assert_equal "text/plain", last_response.headers["Content-Type"]
      end
    end
  end

  describe "timestamp" do
    around do |&block|
      metadata["package"].delete("timestamp")
      super(&block)
    end

    it "is omitted if not present in the metadata" do
      stub_env "RAILS_ENV" => nil, "RACK_ENV" => nil do
        get "/"

        assert last_response.ok?
        assert_equal "UNKNOWN: d0cb1ff", last_response.body
        assert_equal "text/plain", last_response.headers["Content-Type"]
      end
    end
  end
end
