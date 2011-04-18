require 'test_helper'

class MetaMetaFlushTest < Test::Unit::TestCase

  def test_threefold
    assert_nothing_raised do
      3.times { Limbo.chain.flush! }
    end
  end

  def test_class_before
    Limbo.chain.before(:yakshemash, proc { raise(ScriptError) })
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
end