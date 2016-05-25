# frozen_string_literal: true

gem 'minitest'
require 'rack/test'
require 'minitest/autorun'
require 'minitest/pretty_diff'
require 'minitest/focus'
require 'minitest/moar'
require 'minitest/bisect'
require 'minitest/hooks/default'
require 'timecop'

Timecop.safe_mode = true

require 'cartage/rack'

module Minitest::CartageRackStubs
  def stub_dir_pwd value, *block_args, &block
    stub Dir, :pwd, value, *block_args, &block
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

    stub ENV, :[], mock, *block_args, &block
  end

  def stub_backticks value
    Kernel.send(:alias_method, :__stub_backticks__, :`)
    Kernel.send(:define_method, :`) do |command|
      if value.respond_to?(:call)
        if value.arity.nonzero?
          value.call(command)
        else
          value.call
        end
      else
        value
      end
    end
    yield
  ensure
    Kernel.send(:undef_method, :`)
    Kernel.send(:alias_method, :`, :__stub_backticks__)
    Kernel.send(:undef_method, :__stub_backticks__)
  end

  def stub_pathname_exist?(result)
    Pathname.send(:alias_method, :__stub_pathname_exist__, :exist?)
    Pathname.send(:define_method, :exist?) do
      if result.respond_to?(:call)
        if result.arity == 1
          result.call(self)
        else
          result.call
        end
      else
        result
      end
    end
    yield
  ensure
    Pathname.send(:undef_method, :exist?)
    Pathname.send(:alias_method, :exist?, :__stub_pathname_exist__)
    Pathname.send(:undef_method, :__stub_pathname_exist__)
  end

  Minitest::Test.send(:include, self)
end

class << Minitest::Spec
  alias context describe
  private :context
end
