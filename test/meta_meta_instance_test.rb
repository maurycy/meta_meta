require 'test_helper'

class MetaMetaInstanceTest < Test::Unit::TestCase

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