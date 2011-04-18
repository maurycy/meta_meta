require 'test_helper'

class MetaMetaReplaceTest < Test::Unit::TestCase

  def test_replace
    Limbo.chain.replace(:yakshemash, :p)

    limbo = Limbo.new
    
    assert_equal 1, limbo.yakshemash
    assert_equal 1, limbo.toll
  end
end