# -*- ruby encoding: utf-8 -*-

require 'minitest_config'

describe Cartage::RackChangelog do
  include Rack::Test::Methods

  let(:app) { Cartage::RackChangelog.mount(path) }
  let(:path) { 'test/application' }

  it 'inspects nicely for `rake routes` in Rails' do
    stub_dir_pwd path do
      assert_equal 'Cartage::RackChangelog for application', Cartage::RackChangelog.mount.inspect
    end
  end

  it 'returns text/plain content by default' do
    instance_stub Cartage::RackChangelog, :read_changelog, 'ref' do
      get '/'

      assert_equal 'text/plain', last_response.header['Content-Type']
    end
  end

  it 'returns application/json content when requested' do
    instance_stub Cartage::RackChangelog, :read_changelog, 'ref' do
      get '/.json'

      assert_equal 'application/json', last_response.header['Content-Type']
    end
  end

  describe 'read_changelog' do
    it 'looks for release_changelog' do
      instance_stub Pathname, :exist?, true do
        instance_stub Pathname, :readlines, "file-contents\n" do
          get '/'

          assert last_response.ok?
          assert_equal "file-contents\n", last_response.body
        end
      end
    end

    it 'defaults to a string value' do
      stub_env({ 'RAILS_ENV' => 'x' }) do
        instance_stub Pathname, :exist?, false do
          instance_stub Pathname, :directory?, false do
            get '/'

            assert last_response.ok?
            assert_equal "File doesn't exist",
              last_response.body
          end
        end
      end
    end
  end
end
