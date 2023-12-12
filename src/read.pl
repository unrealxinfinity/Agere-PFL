% Reads the input from the user and verifies if it is valid
% read_number_input(+Min,+Max,-Result)
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
	format("Please submit a valid input\n", []),
	skip_line,
	read_number_input(Min, Max, Result).





% Reads numbers of bigger digits from the user and verifies if it is valid
% read_numbers(+Min,+Max,-Result,+LetterInput,+BoardSize)
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


% Verifies if the number is between the min and max
verify_between(Min, Max, Numbers, Numbers, _, _):-
	between(Min, Max, Numbers),
	!,
	skip_line.

verify_between(Min, Max, _, Result, _, 0):-
	write('Please submit a value below '),
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




	

% Assigns input to the correct variable
% assign_input(+Input1,+Input2,-Result)
assign_input(Input1, Input2, Input1):-
	var(Input2),
	!.

assign_input(_, Input2, Input2).
	


% Reads the position input from the user and verifies if it is valid
% read_player(+BoardSize,-LetterInput,-NumberInput)
read_player(BoardSize,LetterInput, NumberInput):-
    	read_letter(BoardSize, LetterInput, NumberInput).
	
% Reads the letter input from the user and verifies if it is valid
% read_letter(+BoardSize,-LetterInput,-NumberInput)
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
	format("Please submit a correct letter\n", []),
	nl,
	skip_line,
	read_player(BoardSize, LetterInput, NumberInput).

% Waits for enter to be pressed
% await_enter/0
await_enter :-
	peek_char(X),
	X = '\n',	
	!,
	skip_line.

await_enter :-
	format("Please type enter to continue\n\n", []),
	nl,
	skip_line,
	await_enter.
	
	



 
	
	
	