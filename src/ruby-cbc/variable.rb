module RubyCBC
  class Variable
    attr_reader :id, :min, :max
    
    def initialize(id, min = 0, max = nil)
      @id = id
      @min = min
      @max = max
    end
    
    def +(other)
      Linear.from(self) + other
    end
    
    def *(other)
      Linear.from(self) * other
    end
    
    def <=(other)
      Linear.from(self) <= other
    end
    
    def >=(other)
      Linear.from(self) >= other
    end
    
    def to_s
      id.to_s
    end
  end
  
  class IntegerVariable < Variable
  end
  
  class BinaryVariable < IntegerVariable
    def initialize(id)
      super(id, 0, 1)
    end
  end
end