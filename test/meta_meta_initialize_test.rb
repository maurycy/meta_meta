require 'test_helper'

class MetaMetaInitializeTest < Test::Unit::TestCase

  def test_initialize_with_block
    Limbo.chain(true) { remove(:yakshemash) }

    limbo = Limbo.new

    assert ! limbo.class.method_defined?(:yakshemash)
    assert_equal 0, limbo.toll
  end
  
  # XXX: meta_meta_instance_test ?
  def test_instance_without_chain_symbol
    3.times { Limbo.chain.before(:yakshemash, :p) }
    
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.without_chain(:yakshemash)
    assert_equal 0, limbo.toll
  end
  
  def test_instance_without_chain_binding
    5.times { Limbo.chain.before(:yakshemash, :p) }
    
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.without_chain { yakshemash }
    assert_equal 0, limbo.toll
  end
end