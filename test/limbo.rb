class Limbo
  attr_accessor :toll
  
  def initialize
    @toll = 0
  end
  
  def yakshemash
    '#winning'
  end
  
  def p
    @toll += 1
  end
  
  def m
    @toll -= 1
  end
end