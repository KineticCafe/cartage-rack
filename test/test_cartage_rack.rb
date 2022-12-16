# frozen_string_literal: true

require "minitest_helper"

describe Cartage::Rack do
  include Rack::Test::Methods

  let(:app) { Cartage::Rack(path) }
  let(:path) { "test/hillvalley" }
  let(:metadata) {
    {
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

  it "inspects nicely for `rake routes` in Rails" do
    assert_equal "Cartage::Rack for hillvalley (release_metadata_json)",
      Cartage::Rack().inspect
  end

  it "returns application/json content by default" do
    get "/"
    assert_equal "application/json", last_response.headers["Content-Type"]
  end

  it "returns text/plain content when requested" do
    get "/.txt"
    assert_equal "text/plain", last_response.headers["Content-Type"]
  end

  describe "application environment" do
    it "uses $RAILS_ENV first" do
      stub_env "RAILS_ENV" => "vne_sliar",
        "APP_ENV"   => "vne_ppa",
        "RACK_ENV"  => "vne_kcar" do
        get "/"

        metadata["env"] = {"name" => "vne_sliar"}

        assert last_response.ok?
        assert_equal metadata.to_json, last_response.body
        assert_equal "application/json", last_response.headers["Content-Type"]
      end
    end

    it "uses $APP_ENV second" do
      stub_env "RAILS_ENV" => nil, "APP_ENV" => "vne_ppa", "RACK_ENV" => "vne_kcar" do
        get "/"

        metadata["env"] = {"name" => "vne_ppa"}

        assert last_response.ok?
        assert_equal metadata.to_json, last_response.body
        assert_equal "application/json", last_response.headers["Content-Type"]
      end
    end

    it "uses $RACK_ENV third" do
      stub_env "RAILS_ENV" => nil, "APP_ENV" => nil, "RACK_ENV" => "vne_kcar" do
        get "/"

        metadata["env"] = {"name" => "vne_kcar"}

        assert last_response.ok?
        assert_equal metadata.to_json, last_response.body
        assert_equal "application/json", last_response.headers["Content-Type"]
      end
    end

    it "falls through to UNKNOWN without either $RAILS_ENV, $APP_ENV or $RACK_ENV" do
      stub_env "RAILS_ENV" => nil, "APP_ENV" => nil, "RACK_ENV" => nil do
        get "/"

        metadata["env"] = {"name" => "UNKNOWN"}

        assert last_response.ok?
        assert_equal metadata.to_json, last_response.body
        assert_equal "application/json", last_response.headers["Content-Type"]
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

        metadata["env"] = {"name" => "UNKNOWN"}

        assert last_response.ok?
        assert_equal metadata.to_json, last_response.body
        assert_equal "application/json", last_response.headers["Content-Type"]
      end
    end
  end

  describe "text/plain" do
    it "returns a useful plaintext format" do
      stub_env "RAILS_ENV" => "production" do
        get "/.text"

        assert last_response.ok?
        assert_equal <<~TEXT.chomp, last_response.body
          name: hillvalley
          environment: production
          hashref: d0cb1ff
          timestamp: 19851027104200
          git: git:doc@hillvalley.com/delorean.git
        TEXT
        assert_equal "text/plain", last_response.headers["Content-Type"]
      end
    end

    it "skips the repo if package.repo is missing" do
      stub_env "RAILS_ENV" => "production" do
        metadata["package"].delete("repo")

        get "/.text"

        assert last_response.ok?
        assert_equal <<~TEXT.chomp, last_response.body
          name: hillvalley
          environment: production
          hashref: d0cb1ff
          timestamp: 19851027104200
        TEXT
        assert_equal "text/plain", last_response.headers["Content-Type"]
      end
    end

    it "skips the timestamp if package.timestamp is missing" do
      stub_env "RAILS_ENV" => "production" do
        metadata["package"].delete("timestamp")

        get "/.text"

        assert last_response.ok?
        assert_equal <<~TEXT.chomp, last_response.body
          name: hillvalley
          environment: production
          hashref: d0cb1ff
          git: git:doc@hillvalley.com/delorean.git
        TEXT
        assert_equal "text/plain", last_response.headers["Content-Type"]
      end
    end
  end

  describe "filter" do
    let(:app) {
      Cartage::Rack(path) { |content|
        content["env"]["name"] = content["env"]["name"].reverse
      }
    }

    it "applies the filter before returning" do
      stub_env "RAILS_ENV" => "vne_sliar" do
        get "/"

        metadata["env"] = {"name" => "rails_env"}

        assert last_response.ok?
        assert_equal metadata.to_json, last_response.body
        assert_equal "application/json", last_response.headers["Content-Type"]
      end
    end
  end
end
