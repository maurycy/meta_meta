require 'test_helper'

class MetaMetaNewTest < Test::Unit::TestCase

  def test_new
    limbo = Limbo.new

    assert '#winning', limbo.yakshemash
    assert_equal 0, limbo.toll
  end

  def test_new_with_block
    Limbo.chain(true) { remove(:yakshemash) }

    limbo = Limbo.new

    assert ! limbo.class.method_defined?(:yakshemash)
    assert_equal 0, limbo.toll
  end
end