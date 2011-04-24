require 'test_helper'

# XXX: s/meta_meta_before_test/meta_meta_after_before_test/
class MetaMetaBeforeTest < Test::Unit::TestCase

  def test_before
    Limbo.chain.before(:yakshemash, :p)
    Limbo.new.tap do |limbo|
      assert_equal '#winning',  limbo.yakshemash
      assert_equal 1,           limbo.toll
    end
  end
  
  def test_before_twice
    Limbo.chain.before(:yakshemash, :p)
    Limbo.chain.before(:yakshemash, :p)
    Limbo.new.tap do |limbo|
      assert_equal '#winning',  limbo.yakshemash
      assert_equal 2,           limbo.toll
    end
  end
  
  def test_before_array
    Limbo.chain.before(:yakshemash, [:p, :p, :p, :m, :p])
    Limbo.new.tap do |limbo|
      assert_equal '#winning',  limbo.yakshemash
      assert_equal 3,           limbo.toll
    end
  end
  
  def test_before_lambda
    Limbo.chain.before(:yakshemash, lambda { self.toll = 'hlcrlwrld'})
    Limbo.new.tap do |limbo|
      assert_equal '#winning',  limbo.yakshemash
      assert_equal 'hlcrlwrld', limbo.toll
    end
  end
  
  def test_before_implicit_array
    Limbo.chain.before(:yakshemash, :p, :p, :p, :m)
    Limbo.new.tap do |limbo|
      assert_equal '#winning',  limbo.yakshemash
      assert_equal 2,           limbo.toll
    end
  end
  
  def test_before_implicit_array_lambda
    Limbo.chain.before(:yakshemash, :p, :p, :p, lambda { self.toll -= 7 })
    Limbo.new.tap do |limbo|
      assert_equal '#winning',  limbo.yakshemash
      assert_equal (3 - 7),     limbo.toll
    end
  end
  
  def test_before_implicit_array_proc
    Limbo.chain.before(:yakshemash, :p, :p, proc { self.toll -= 5 })
    Limbo.new.tap do |limbo|
      assert_equal '#winning',  limbo.yakshemash
      assert_equal (2 - 5),     limbo.toll
    end
  end
  
  def test_before_implicit_array_proc_new
    Limbo.chain.before(:yakshemash, :p, :p, :p, :p, Proc.new {self.toll = 0})
    Limbo.new.tap do |limbo|
      assert_equal '#winning',  limbo.yakshemash
      assert_equal 0,           limbo.toll
    end
  end
  
  def test_before_undefined
    Limbo.chain.before(:happiness, :p)
    Limbo.new.tap do |limbo|
      assert_raise(NoMethodError) { limbo.happiness }
      
      assert_equal '#winning',  limbo.yakshemash
      assert_equal 0,           limbo.toll
    end
  end
  
  def test_before_lazy
    Limbo.chain.before(:happiness, :p)
    Limbo.class_eval do
      def happiness; :zegna; end
    end
    Limbo.new.tap do |limbo|
      assert_equal :zegna,  limbo.happiness
      assert_equal 1,       limbo.toll
    end
  end
  
  def test_before_overwritten
    Limbo.chain.before(:yakshemash, :p)
    Limbo.class_eval do
      def yakshemash; :five_hundred_days_of_summer; end
      def yakshemash; :five_hundred_days_of_winter; end
    end
    Limbo.new.tap do |limbo|
      assert_equal :five_hundred_days_of_winter,  limbo.yakshemash
      assert_equal 1,                             limbo.toll
    end
  end
end