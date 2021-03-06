%%{
  machine cbc;
  
  action raise_error {
    raise ParseError, "Error parsing CBC solution near #{(data[p-10...p] + "[" + data[p] + "]" + data[p+1..p+10]).inspect} in state #{cs}";
  }
  
  action save_number {
    number = data[saved_position...p].to_f;
  }
  
  action log_position {
    saved_position = p;
  }
  
  action finish_variable {
    variable_name = data[saved_position...p];
  }
  
  action save_objective_value {
    objective_value = number
    objective_value = -objective_value if problem.goal_inverted?
  }
  
  action save_coefficient {
    variable_values[variable_name] = number;
  }
  
  action mark_optimal {
    is_optimal = true
  }
  
  newline = "\n";
  
  number = (('+' | '-')? digit+ ('.' digit+)? ('e' ('+' | '-') digit+)? ) > log_position % save_number;
  
  variable_name = ([A-Za-z]+[A-Za-z0-9]+) >log_position %finish_variable;
  
  objective_value = " - objective value" space+ number %save_objective_value space* :> newline;
  
  solution_line = space* number space+ variable_name space+ number %save_coefficient space+ number space* :> newline;
  
  optimum = "Optimal" @mark_optimal objective_value solution_line**;
  
  timeout = "Stopped on " ("iterations" | "time" | "iterations or time") objective_value solution_line**;
  
  found_solution = optimum | timeout;
  
  infeasible = "Infeasible" @{return};
  
  unbounded = "Unbounded" @{return};
  
  main := (found_solution | infeasible | unbounded) @/raise_error $!raise_error;
}%%

module RubyCBC
  class ParseError < Exception
  end
  
  class Solution
    %% write data;
    
    attr_reader :problem, :objective_value, :variable_values
    
    def initialize(problem, objective_value, variable_values, optimal)
      @problem = problem
      @objective_value = objective_value
      @variable_values = variable_values
      @optimal = optimal
    end
    
    def [](v)
      v.extract_solution_value(self)
    end
    
    def optimal?
      @optimal
    end
    
    def self.parse(data, problem)
      number = 0
      saved_position = nil
      variable_name = nil
      objective_value = nil
      variable_values = {}
      is_optimal = false
      
      %% write init;
      
      # Force this to hit EOF at the end of the data string
      eof = pe
      
      %% write exec;
      
      Solution.new(problem, objective_value, variable_values, is_optimal)
    end
  end
end
