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






read_numbers(Min, Max, Result, LetterInput, BoardSize):-
	read_numbers_input(0, Numbers),
	verify_between(Min, Max, Numbers, Result, LetterInput, BoardSize).


read_numbers_input(Acc, Acc):-
	peek_char(X),
	X = '\n'.

read_numbers_input(Acc, Result):-
	get_code(Asci),
	Acc1 is Acc * 10 + Asci - 48,
	read_numbers_input(Acc1 , Result).



verify_between(Min, Max, Numbers, Numbers, _, _):-
	between(Min, Max, Numbers),
	!,
	skip_line.

verify_between(Min, Max, _, Result, _, 0):-
	draw_message('Please type a number below '),
	write(Max),
	skip_line,
	!,
	nl,
	read_numbers(Min, Max, Result, _, 0).

verify_between(_, Max, _, Result, LetterInput, BoardSize):-
	write('Please submit a value below '),
	write(Max),
	skip_line,
	nl,
	read_player(BoardSize, LetterInput, Result).




	


assign_input(Input1, Input2, Input1):-
	var(Input2),
	!.

assign_input(_, Input2, Input2).
	



read_player(BoardSize,LetterInput, NumberInput):-
    	read_letter(BoardSize, LetterInput, NumberInput).
	

read_letter(BoardSize, LetterInput, NumberInput):-
	peek_char(X),
	X \= '\n',
    	get_code(Ascii),
	LetterInput1 is Ascii-96,
    	between(1,BoardSize,LetterInput1),
	!,
	NumberMax is BoardSize+(BoardSize-1),
	read_numbers(1, NumberMax, NumberInput, LetterInput2, BoardSize),
	assign_input(LetterInput1, LetterInput2, LetterInput).

read_letter(BoardSize, LetterInput, NumberInput):-
	draw_message('Please submit a valid letter'),
	nl,
	skip_line,
	read_player(BoardSize, LetterInput, NumberInput).


await_enter :-
	peek_char(X),
	X = '\n',	
	!,
	skip_line.

await_enter :-
	draw_message('Please type enter to continue'),
	nl,
	skip_line,
	await_enter.
	
	



 
	
	
	