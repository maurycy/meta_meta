require 'rubygems'
require 'test/unit'
require 'ruby-debug'

require '../lib/meta_meta'

class MetaMetaTest < Test::Unit::TestCase

  def setup
    # Remove the class.
    Object.send(:remove_const, :Limbo) if Object.const_defined?(:Limbo)

    # Reload the class.
    load 'limbo.rb'
    
    Limbo.class_eval { include(MetaMeta) }
    Limbo.chain.flush
  end

  def test_limbo
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 0, limbo.toll
  end
  
  def test_before
    Limbo.chain.before(:yakshemash, :p)

    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 1, limbo.toll
  end
  
  def test_before_twice
    2.times { Limbo.chain.before(:yakshemash, :p) }
    
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 2, limbo.toll
  end
  
  def test_before_array
    Limbo.chain.before(:yakshemash, [:p, :p, :p, :m, :p])
    
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 3, limbo.toll
  end
  
  def test_before_proc
    Limbo.chain.before(:yakshemash, lambda { self.toll = 'hlcrlwrld'})
    
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 'hlcrlwrld', limbo.toll
  end
  
  def test_before_implicit_array
    Limbo.chain.before(:yakshemash, :p, :p, :p, :m)
    
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 2, limbo.toll
  end
  
  def test_before_implicit_array_proc
    Limbo.chain.before(:yakshemash, :p, :p, :p, lambda { self.toll -= 7 })
    
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal (3 - 7), limbo.toll
  end
  
  def test_before_undefined
    Limbo.chain.before(:happiness, :p)
    
    limbo = Limbo.new

    assert ! limbo.class.method_defined?(:happiness)
    assert_equal '#winning', limbo.yakshemash
    assert_equal 0, limbo.toll
  end
  
  def test_replace
    Limbo.chain.replace(:yakshemash, :p)

    limbo = Limbo.new
    
    assert_equal 1, limbo.yakshemash
    assert_equal 1, limbo.toll
  end
  
  def test_remove
    Limbo.chain.remove(:yakshemash)

    limbo = Limbo.new

    assert ! limbo.class.method_defined?(:yakshemash)
    assert_equal 0, limbo.toll
  end
  
  def test_remove_array
    Limbo.chain.remove([:yakshemash, :p, :m])

    limbo = Limbo.new

    assert ! limbo.class.method_defined?(:yakshemash)
    assert ! limbo.class.method_defined?(:p)
    assert ! limbo.class.method_defined?(:m)
    assert_equal 0, limbo.toll
  end
  
  def test_remove_implicit_array
    Limbo.chain.remove(:yakshemash, :p, :m)

    limbo = Limbo.new

    assert ! limbo.class.method_defined?(:yakshemash)
    assert ! limbo.class.method_defined?(:p)
    assert ! limbo.class.method_defined?(:m)
    assert_equal 0, limbo.toll
  end
  
  def test_remove_revert
    Limbo.chain.remove(:yakshemash)
    Limbo.chain.flush
    
    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 0, limbo.toll
  end
  
  def test_remove_revert_array
    Limbo.chain.remove([:yakshemash, :p, :m])
    Limbo.chain.flush

    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 0, limbo.toll
  end
  
  def test_remove_revert_implicit_array
    Limbo.chain.remove(:yakshemash, :p, :m)
    Limbo.chain.flush

    limbo = Limbo.new
    
    assert_equal '#winning', limbo.yakshemash
    assert_equal 0, limbo.toll
  end
  
  def test_initialize_with_block
    Limbo.chain(true) { remove(:yakshemash) }

    limbo = Limbo.new

    assert ! limbo.class.method_defined?(:yakshemash)
    assert_equal 0, limbo.toll
  end
  
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