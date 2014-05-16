module RubyCBC
  class Linear
    attr_reader :weights, :constant
    
    def initialize(init = {}, constant = 0)
      @weights = init
      @constant = constant
    end
    
    def +(other)
      other = Linear.from(other)
      
      new_weights = weights.dup
      other.weights.each do |var, weight|
        if new_weights.has_key?(var)
          new_weights[var] += weight
        else
          new_weights[var] = weight
        end
      end
      Linear.new(new_weights, constant + other.constant)
    end
    
    def -(other)
      self + (Linear.from(other) * -1)
    end
    
    def *(other)
      if not other.kind_of? Numeric
        raise "Can only multiply a linear expression by a number"
      end
      
      new_weights = {}
      @weights.each do |var, weight|
        new_weights[var] = weight * other
      end
        
      Linear.new(new_weights, constant * other)
    end
    
    def >=(other)
      diff = self - Linear.from(other)
      Constraint.new(diff)
    end
    
    def <=(other)
      diff = Linear.from(other) - self
      Constraint.new(diff)
    end
    
    def self.from(value)
      if value.kind_of? Linear
        value
      elsif value.kind_of? Variable
        new({value => 1}, 0)
      elsif value.kind_of? Numeric
        new({}, value)
      else
        raise "Attempt to create linear expression from incompatible type"
      end
    end
    
    def to_s(exclude_constant = false)
      s = ""
      @weights.each do |var, weight|
        if s.empty?
          s << "#{weight} #{var}"
        elsif weight < 0
          s << " - #{weight.abs} #{var}"
        else
          s << " + #{weight} #{var}"
        end
      end
      unless exclude_constant
        if @constant > 0
          s << " + #{@constant}"
        elsif @constant < 0
          s << " - #{@constant.abs}"
        end
      end
      s
    end
  end
end