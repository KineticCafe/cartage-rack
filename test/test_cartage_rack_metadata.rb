# frozen_string_literal: true

require 'minitest_config'

describe Cartage::Rack::Metadata do
  let(:described_class) { Cartage::Rack::Metadata }
  let(:path) { 'test/hillvalley' }
  let(:env) { { 'RAILS_ENV' => 'production' } }

  context 'with release-metadata.json' do
    let(:expected) {
      {
        'env' => { 'name' => 'production' },
        'package' => {
          'name' => 'hillvalley',
          'repo' => {
            'type' => 'git',
            'url' => 'git:doc@hillvalley.com/delorean.git'
          },
          'hashref' => 'd0cb1ff',
          'timestamp' => '19851027104200'
        }
      }
    }

    it '#inspect uses the source (release_metadata_json) for inspection' do
      stub_pathname_exist? ->(v) { v.basename.to_s == 'release-metadata.json' } do
        instance_stub Pathname, :read, '{}' do
          assert_match(
            /\Ahillvalley \(release_metadata_json\)\z/,
            described_class.new(path, required: false).inspect
          )
        end
      end
    end

    it '#resolve returns the content as provided' do
      stub_env(env) do
        stub_pathname_exist? ->(v) { v.basename.to_s == 'release-metadata.json' } do
          instance_stub Pathname, :read, expected.to_json do
            assert_equal expected, described_class.new(path).resolve
          end
        end
      end
    end

    it '#resolve returns filtered content' do
      filter = ->(content) {
        content['env']['capacitor'] = 'flux'
      }

      stub_env(env) do
        stub_pathname_exist? ->(v) { v.basename.to_s == 'release-metadata.json' } do
          instance_stub Pathname, :read, expected.to_json do
            expected['env']['capacitor'] = 'flux'
            assert_equal expected, described_class.new(path, filter: filter).resolve
          end
        end
      end
    end

    it '.new throws an exception with a non-JSON file' do
      stub_env(env) do
        stub_pathname_exist? ->(v) { v.basename.to_s == 'release-metadata.json' } do
          instance_stub Pathname, :read, 'supercalafragalisticexpealadocious' do
            ex = assert_raises(JSON::ParserError) do
              described_class.new(path)
            end

            assert_match(/unexpected token/, ex.message)
          end
        end
      end
    end
  end

  context 'with release_hashref' do
    let(:one_line) { 'd0cb1ff' }
    let(:two_line) { "d0cb1ff\n19851027104200\n" }
    let(:two_line_empty) { "d0cb1ff\n\n" }
    let(:three_line) { "d0cb1ff\n19851027104200\nsomethingelse\n" }
    let(:expected_notimestamp) {
      {
        'env' => {
          'name' => 'production'
        },
        'package' => {
          'name' => 'hillvalley',
          'hashref' => 'd0cb1ff'
        }
      }
    }
    let(:expected_timestamp) {
      expected_notimestamp.dup.tap do |en|
        en['package'] = en['package'].merge('timestamp' => '19851027104200')
      end
    }

    it 'uses the source (release_hashref) for inspection' do
      stub_pathname_exist? ->(v) { v.basename.to_s == 'release_hashref' } do
        instance_stub Pathname, :read, '' do
          assert_match(
            /\Ahillvalley \(release_hashref\)\z/,
            described_class.new(path, required: false).inspect
          )
        end
      end
    end

    context '#resolve' do
      it 'returns the hashref from a one line release_hashref' do
        stub_env(env) do
          stub_pathname_exist? ->(v) { v.basename.to_s == 'release_hashref' } do
            instance_stub Pathname, :read, one_line do
              assert_equal expected_notimestamp, described_class.new(path).resolve
            end
          end
        end
      end

      it 'returns hashref and timestamp from a two line release_hashref' do
        stub_env(env) do
          stub_pathname_exist? ->(v) { v.basename.to_s == 'release_hashref' } do
            instance_stub Pathname, :read, two_line do
              assert_equal expected_timestamp, described_class.new(path).resolve
            end
          end
        end
      end

      it 'returns hashref from a two line release_hashref (with empty timestamp line)' do
        stub_env(env) do
          stub_pathname_exist? ->(v) { v.basename.to_s == 'release_hashref' } do
            instance_stub Pathname, :read, two_line_empty do
              assert_equal expected_notimestamp, described_class.new(path).resolve
            end
          end
        end
      end

      it 'ignores anything larger than two lines in release_hashref' do
        stub_env(env) do
          stub_pathname_exist? ->(v) { v.basename.to_s == 'release_hashref' } do
            instance_stub Pathname, :read, three_line do
              assert_equal expected_timestamp, described_class.new(path).resolve
            end
          end
        end
      end
    end
  end

  context 'with live data' do
    it 'uses the source (live) for inspection' do
      instance_stub Pathname, :exist?, false do
        assert_match(
          /\(live\)\z/,
          described_class.new(path, required: false).inspect
        )
      end
    end

    let(:expected_nogit) {
      {
        'env' => {
          'name' => 'production'
        },
        'package' => {
          'name' => 'hillvalley',
          'hashref' => 'UNKNOWN - no .git directory',
          'timestamp' => '19851027104200'
        }
      }
    }
    let(:expected_git) {
      expected_nogit.dup.tap { |en|
        en['package'] = en['package'].merge(
          'repo' => {
            'type' => 'git',
            'url' => 'git:doc@hillvalley.com/delorean.git'
          },
          'hashref' => '(git) verne'
        )
      }
    }

    it 'fails if required is true' do
      ex = assert_raises(RuntimeError) do
        described_class.new(path, required: true)
      end

      assert_equal 'Cannot find release-metadata.json or release_hashref', ex.message
    end

    context '#resolve' do
      around do |&block|
        Timecop.freeze(Time.new(1985, 10, 27, 2, 42, 0, '-08:00')) do
          super(&block)
        end
      end

      it 'excludes package.repo when no .git directory' do
        stub_env(env) do
          instance_stub Pathname, :exist?, false do
            instance_stub Pathname, :directory?, false do
              assert_equal expected_nogit,
                described_class.new(path, required: false).resolve
            end
          end
        end
      end

      it 'includes package.repo when a .git directory exists' do
        backticks = ->(v) {
          case v
          when /remote show/
            "\n  Fetch URL: git:doc@hillvalley.com/delorean.git"
          when /rev-parse/
            'verne'
          else
            __stub_backticks__(v)
          end
        }

        stub_env(env) do
          stub_backticks backticks do
            instance_stub Pathname, :exist?, false do
              instance_stub Pathname, :directory?, true do
                assert_equal expected_git,
                  described_class.new(path, required: false).resolve
              end
            end
          end
        end
      end
    end
  end
end
