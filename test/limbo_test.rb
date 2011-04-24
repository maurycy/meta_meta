require 'test_helper'

class MetaMetaTest < Test::Unit::TestCase

  def setup # XXX: DRY
    # Remove the class.
    Object.send(:remove_const, :Limbo) if Object.const_defined?(:Limbo)

    # Reload the class.
    load 'limbo.rb'
    
    Limbo.class_eval { include(MetaMeta) }
    Limbo.chain.flush!
  end

  def test_initialize
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 0, limbo.toll
  end
end