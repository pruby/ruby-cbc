module RubyCBC
  class Constraint
    attr_reader :weights, :constant
    
    def initialize(linear)
      @linear = linear
    end
    
    def to_s
      s = (@linear * -1).to_s(true)
      s << " <= "
      s << @linear.constant.to_s
      s
    end
  end
end
