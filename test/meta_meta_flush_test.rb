require 'test_helper'

class MetaMetaFlushTest < Test::Unit::TestCase

  def test_threefold
    assert_nothing_raised do
      3.times { Limbo.chain.flush! }
    end
  end

  def test_class_before
    Limbo.chain.before(:yakshemash, proc { raise('hll,crlwrld') })
    Limbo.chain.flush!
    
    assert_nothing_raised do
      limbo = Limbo.new
      assert_equal '#winning', limbo.yakshemash
    end
  end

  def test_class_remove
    Limbo.chain.remove(:yakshemash)
    Limbo.chain.flush!

    limbo = Limbo.new
    assert_equal '#winning', limbo.yakshemash
  end
  
  def test_instance_remove
    limbo = Limbo.new
    limbo.chain.remove(:yakshemash)
    limbo.chain.flush!

    assert_equal '#winning', limbo.yakshemash
  end
  
  def test_replace_defined
    Limbo.chain.replace(:yakshemash, :anunhappy)
    Limbo.class_eval do
      def yakshemash; :an_unhappy_birthday; end
      def yakshemash; :you_lie; end
    end
    Limbo.chain.flush!
    
    Limbo.new.tap do |limbo|
      assert_equal :you_lie, limbo.yakshemash
    end
  end
  
  def test_replace_undefined
    Limbo.chain.replace(:the_smiths, :behind)
    Limbo.class_eval do
      def the_smiths; :an_unhappy_birthday; end
      def the_smiths; :you_lie; end
    end
    Limbo.chain.flush!
    
    Limbo.new.tap do |limbo|
      assert_equal :you_lie, limbo.the_smiths
    end
  end
end