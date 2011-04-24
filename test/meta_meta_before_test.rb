require 'test_helper'

# XXX: s/meta_meta_before_test/meta_meta_after_before_test/
class MetaMetaBeforeTest < Test::Unit::TestCase

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
end