require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'ruby-debug'
require 'meta_meta'

class Test::Unit::TestCase

  # XXX
  def setup
    # Remove the class.
    Object.send(:remove_const, :Limbo) if Object.const_defined?(:Limbo)

    # Reload the class.
    load 'limbo.rb'
    
    Limbo.class_eval { include(MetaMeta) }
    Limbo.chain.flush
  end
end
