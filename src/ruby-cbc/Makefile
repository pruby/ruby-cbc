default: solution.rb

viz: solution.ps

solution.rb: solution.rl
	ragel -R -T1 -o $@ $<

solution.ps: solution.rl
	ragel -Vp -o /dev/stdout $< | dot -Tps -o $@
	
