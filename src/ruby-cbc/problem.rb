require 'tempfile'

module RubyCBC
  class Problem
    attr_reader :constraints
    
    def initialize
      @goal = nil
      @mode = :maximise
      @variables = []
      @constraints = []
    end
    
    def binary
      variable = BinaryVariable.new(next_variable_id)
      @variables << variable
      variable
    end
    alias_method :decision, :binary
    
    def integer(min = nil, max = nil)
      if min.kind_of?(Range)
        range = min
        min = range.begin
        max = range.end
      end
      
      variable = IntegerVariable.new(next_variable_id, min, max)
      
      @variables << variable
      variable
    end
    
    def variable(min = nil, max = nil)
      if min.kind_of?(Range)
        range = min
        min = range.begin
        max = range.end
      end
      
      variable = Variable.new(next_variable_id, min, max)
      
      @variables << variable
      variable
    end
    
    def constraint(c)
      @constraints << c
    end
    
    def maximise(goal)
      @goal = goal
      @mode = :maximize
    end
    alias_method :maximize, :maximise
    
    def minimise(goal)
      @goal = goal
      @mode = :minimize
    end
    alias_method :minimize, :minimise
    
    def write_lp(out)
      out.puts @mode.to_s.capitalize
      out.puts "Goal: " + @goal.to_s
      out.puts "Subject To"
      @constraints.each_with_index do |constraint, i|
        out.puts "C#{i}: #{constraint}"
      end
      out.puts "Bounds"
      @variables.each do |variable|
        next if variable.kind_of?(BinaryVariable)
        out.puts [variable.min || "-infinity", variable.id, variable.max || "infinity"].join(' <= ')
      end
      out.puts "Generals"
      @variables.each do |variable|
        if variable.kind_of?(IntegerVariable) && !(variable.kind_of?(BinaryVariable))
          out.puts variable.id
        end
      end
      out.puts "Binaries"
      @variables.each do |variable|
        if variable.kind_of?(BinaryVariable)
          out.puts variable.id
        end
      end
      out.puts "End"
    end
    
    def solve
      tmp = Tempfile.new(['lp', '.lp'])
      tmp_sol = Tempfile.new(['lp', '.sol'])
      tmp_sol.close
      
      begin
        write_lp(tmp)
        tmp.close
        
        `cbc #{tmp.path} quiet branch solution #{tmp_sol.path}`
        @result_lines = File.read(tmp_sol.path)
        puts @result_lines
      ensure
        begin
          tmp.close
          tmp_sol.close
        rescue => e
          # May already be closed
        end
        tmp.unlink
        tmp_sol.unlink
      end
    end
    
    private
    
    def next_variable_id
      "v" + @variables.length.to_s
    end
  end
end
