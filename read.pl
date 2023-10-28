read_number_input(Min, Max, Result):-
	get_code(Asci),
	peek_char(X),
	X = '\n',
	Result is Asci - 48,
	between(Min, Max, Result), 
	skip_line,
	!,
	clear_screen.

read_number_input(Min, Max, Result):-
	write('Please submit a valid input\n'),
	skip_line,
	read_number_input(Min, Max, Result).

read_numbers(Min, Max, Result):-
	read_numbers_input(0, Result, Min, Max).


read_numbers_input(Acc, Result, Min, Max):-
	peek_char(X),
	X = '\n',
	verify_between(Min, Max, Acc, Result).

read_numbers_input(Acc, Result, Min, Max):-
	get_code(Asci),
	Acc1 is Acc * 10 + Asci - 48,
	read_numbers_input(Acc1 , Result, Min, Max).



verify_between(Min, Max, Acc, Result):-
	between(Min, Max, Acc),
	Result is Acc,
	skip_line.

verify_between(Min, Max, _, Result):-
	write('Please submit a value below 15\n'),
	skip_line,
	read_numbers(Min, Max, Temp),
	Result is Temp.
	
	
	