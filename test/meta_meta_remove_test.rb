require 'test_helper'

class MetaMetaRemoveTest < Test::Unit::TestCase

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
  
  def test_remove_with_class_overwrite
    Limbo.chain.remove(:yakshemash, :p, :m)
    Limbo.class_eval do
      def yakshemash
        '#biwinning'
      end
    end

    limbo = Limbo.new
    
    assert_equal '#biwinning', limbo.yakshemash
    assert_equal 0, limbo.toll
  end
  
  def test_remove_with_instance_overwrite
    Limbo.chain.remove(:yakshemash, :p, :m)

    limbo, dante = Limbo.new, Limbo.new
    limbo.instance_eval do
      def yakshemash
        '#biwinning'
      end
    end

    assert ! dante.respond_to?(:yakshemash)
    # assert ! dante.class.method_defined?(:yakshemash)
    assert_raise(NoMethodError) { dante.yakshemash }
    
    assert   limbo.respond_to?(:yakshemash)
    # assert   limbo.class.method_defined?(:yakshemash)
    assert_nothing_raised(NoMethodError) { limbo.yakshemash}
    assert_equal '#biwinning', limbo.yakshemash
  end
end