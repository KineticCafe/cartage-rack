# -*- ruby encoding: utf-8 -*-

require 'minitest_config'

describe Cartage::Rack do
  include Rack::Test::Methods

  let(:app) { Cartage::Rack.mount(path) }
  let(:path) { 'test/application' }

  it 'inspects nicely for `rake routes` in Rails' do
    stub_dir_pwd path do
      assert_equal 'Cartage::Rack for application', Cartage::Rack.mount.inspect
    end
  end

  it 'returns text/plain content by default' do
    instance_stub Cartage::Rack, :application_env, 'env' do
      instance_stub Cartage::Rack, :release_hashref, 'ref' do
        get '/'

        assert_equal 'text/plain', last_response.header['Content-Type']
      end
    end
  end

  it 'returns application/json content when requested' do
    instance_stub Cartage::Rack, :application_env, 'env' do
      instance_stub Cartage::Rack, :release_hashref, 'ref' do
        get '/.json'

        assert_equal 'application/json', last_response.header['Content-Type']
      end
    end
  end

  describe 'application_env' do
    it 'uses RAILS_ENV first' do
      instance_stub Cartage::Rack, :release_hashref, 'release_hashref' do
        stub_env({ 'RAILS_ENV' => 'vne_sliar', 'RACK_ENV' => 'vne_kcar' }) do
          get '/'

          assert last_response.ok?
          assert_equal 'vne_sliar: release_hashref', last_response.body
          assert_equal 'text/plain', last_response.header['Content-Type']
        end
      end
    end

    it 'uses RACK_ENV second' do
      instance_stub Cartage::Rack, :release_hashref, 'release_hashref' do
        stub_env({ 'RACK_ENV' => 'vne_kcar' }) do
          get '/'

          assert last_response.ok?
          assert_equal 'vne_kcar: release_hashref', last_response.body
          assert_equal 'text/plain', last_response.header['Content-Type']
        end
      end
    end

    it 'uses RACK_ENV second' do
      instance_stub Cartage::Rack, :release_hashref, 'release_hashref' do
        stub_env({}) do
          get '/'

          assert last_response.ok?
          assert_equal 'UNKNOWN: release_hashref', last_response.body
          assert_equal 'text/plain', last_response.header['Content-Type']
        end
      end
    end
  end

  describe 'release_hashref' do
    it 'looks for ./release_hashref' do
      stub_env({ 'RAILS_ENV' => 'x' }) do
        instance_stub Pathname, :exist?, true do
          instance_stub Pathname, :read, "file-contents\n" do
            get '/'

            assert last_response.ok?
            assert_equal 'x: file-contents', last_response.body
          end
        end
      end
    end

    it 'looks for ./release_hashref (multi-line)' do
      stub_env({ 'RAILS_ENV' => 'x' }) do
        instance_stub Pathname, :exist?, true do
          instance_stub Pathname, :read, "file-contents\ntimestamp\n" do
            get '/'

            assert last_response.ok?
            assert_equal 'x: file-contents (timestamp)', last_response.body
          end
        end
      end
    end

    it 'looks for .git next' do
      stub_env({ 'RAILS_ENV' => 'x' }) do
        instance_stub Pathname, :exist?, false do
          instance_stub Pathname, :directory?, true do
            stub_backticks 'HEAD' do
              get '/'

              assert last_response.ok?
              assert_equal 'x: (git) HEAD', last_response.body
            end
          end
        end
      end
    end

    it 'defaults to a string value' do
      stub_env({ 'RAILS_ENV' => 'x' }) do
        instance_stub Pathname, :exist?, false do
          instance_stub Pathname, :directory?, false do
            get '/'

            assert last_response.ok?
            assert_equal 'x: UNKNOWN - no release_hashref or .git directory',
              last_response.body
          end
        end
      end
    end
  end
end
