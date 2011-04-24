require 'test_helper'

class MetaMetaReplaceTest < Test::Unit::TestCase

  def test_replace
    Limbo.chain.replace(:yakshemash, :p)
    Limbo.new.tap do |limbo|
      assert_equal 1, limbo.yakshemash
      assert_equal 1, limbo.toll
    end
  end
  
  def test_replace_twice
    2.times { Limbo.chain.replace(:yakshemash, :p) }
    
    Limbo.new.tap do |limbo|
      assert_equal 1, limbo.yakshemash
      assert_equal 1, limbo.toll
    end
  end
  
  def test_replace_overwrite
    Limbo.chain.replace(:yakshemash, :p)
    Limbo.chain.replace(:yakshemash, :m)
    Limbo.new.tap do |limbo|
      assert_equal -1, limbo.yakshemash
      assert_equal -1, limbo.toll
    end
  end
  
  def test_replace_lambda
    Limbo.chain.replace(:yakshemash, lambda {:its_really_serious})
    Limbo.new.tap do |limbo|
      assert_equal :its_really_serious, limbo.yakshemash
    end
  end
  
  def test_replace_proc
    Limbo.chain.replace(:yakshemash, Proc.new {:its_really_serious})
    Limbo.new.tap do |limbo|
      assert_equal :its_really_serious, limbo.yakshemash
    end
  end
  
  def test_replace_nil
    Limbo.chain.replace(:yakshemash, nil)
    assert_raise(NoMethodError) do
      Limbo.new.tap do |limbo|
        limbo.yakshemash
      end
    end
  end
  
  def test_replace_one_param
    Limbo.chain.replace(:yakshemash)
    assert_raise(NoMethodError) do
      Limbo.new.tap do |limbo|
        limbo.yakshemash
      end
    end
  end

  def test_replace_lazy_replaced
    Limbo.chain.replace(:morrissey, :yakshemash)
    Limbo.class_eval do
      def morrissey; :girlfriend_in_a_coma; end
    end
    Limbo.new.tap do |limbo|
      assert_equal '#winning', limbo.yakshemash
      assert_equal '#winning', limbo.morrissey
    end
  end
  
  def test_replace_lazy_replaced_yet
    Limbo.chain.replace(:yakshemash, :morrissey)
    Limbo.new.tap do |limbo|
      assert_equal '#winning', limbo.yakshemash
    end
  end
  
  def test_replace_lazy_replacee
    Limbo.chain.replace(:yakshemash, :morrissey)
    Limbo.class_eval do
      def morrissey; :girlfriend_in_a_coma; end
    end
    Limbo.new.tap do |limbo|
      assert_equal :girlfriend_in_a_coma, limbo.yakshemash
      assert_equal :girlfriend_in_a_coma, limbo.morrissey
    end
  end
end