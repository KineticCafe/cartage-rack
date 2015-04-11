# -*- ruby encoding: utf-8 -*-

gem 'minitest'
require 'rack/test'
require 'minitest/autorun'
require 'minitest/pretty_diff'
require 'minitest/focus'
require 'minitest/moar'
require 'minitest/bisect'

require 'cartage/rack'

module Minitest::ENVStub
  def stub_dir_pwd value, *block_args, &block
    if defined? Minitest::Moar::Stubbing
      stub Dir, :pwd, value, *block_args, &block
    else
      Dir.stub :pwd, value, *block_args, &block
    end
  end

  def stub_env env, options = {}, *block_args, &block
    mock = lambda { |key|
      env.fetch(key) { |k|
        if options[:passthrough]
          ENV.send(:"__minitest_stub__[]", k)
        else
          nil
        end
      }
    }

    if defined? Minitest::Moar::Stubbing
      stub ENV, :[], mock, *block_args, &block
    else
      ENV.stub :[], mock, *block_args, &block
    end
  end

  def stub_backticks value
    Kernel.send(:alias_method, :__stub_backticks__, :`)
    Kernel.send(:define_method, :`) { |*| value }
    yield
  ensure
    Kernel.send(:undef_method, :`)
    Kernel.send(:alias_method, :`, :__stub_backticks__)
    Kernel.send(:undef_method, :__stub_backticks__)
  end

  Minitest::Test.send(:include, self)
end
