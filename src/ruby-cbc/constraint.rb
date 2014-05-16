module RubyCBC
  class Constraint
    attr_reader :weights, :constant
    
    def initialize(linear)
      @linear = linear
    end
    
    def to_s
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
      s << " >= 0"
      s
    end
  end
end
