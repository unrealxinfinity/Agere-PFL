translate(o, ' ').
translate(b, '#').
translate(y, '-').

write_spaces(N) :-
    format('~*|', [N]).


clear_screen :- write('\33\[2J').


draw_piece(Piece):-
	write(Piece).

draw_letter(Size):-
	LetterCode is 65+Size-1,
    	char_code(Letter, LetterCode),
    	write(Letter),
    	write(' ').

draw_color(_, 0).

draw_color(Color, Size):-
	Size > 0,
	write(Color),
	Size1 is Size - 1,
	draw_color(Color, Size1).

draw_numbers(Size, Size).

draw_row_middle_aux([], _):- 
	write('|').
	

draw_row_middle_aux([Piece|List], FontSize):- 
	write('|'),
	translate(Piece, Color),
	draw_color(Color, FontSize),
    	draw_row_middle_aux(List, FontSize).
	

draw_numbers(Size, Counter):-
	Counter =< Size,
	Number is Counter + 1,
	write(Number),
	write(' '),
	draw_numbers(Size, Number).

display_game(GameState):-
	length(GameState, Size),
	nl,
	display_rows(GameState, Size, Size, 3).

display_rows([], _, Size2, _):-
	Size is Size2 + Size2-1,
	draw_numbers(Size, 0).

display_rows([Row | List], Size, Size2, FontSize) :-
	Offset is (Size-1)*FontSize,
	Offset1 is Offset+2,
	write_spaces(Offset),
	draw_letter(Size),
	FontSize2 is FontSize * 2,
    	display_row_middle(Row, FontSize, Offset1, FontSize2),
    	Size1 is Size-1,
    	nl, 
    	display_rows(List, Size1, Size2, FontSize).


display_row_middle(_, 0, _, _).

display_row_middle(Row, Length, Offset, FontSize) :-
	Length > 0,
	draw_row_middle_aux(Row, FontSize),
	nl,
	write_spaces(Offset),
	Length1 is Length-1,
	display_row_middle(Row, Length1, Offset, FontSize).

	
	


draw_logo :-
    	format("\e[1m\e[34m\e[47m      _   / ____|  =====        \e[0m\n", []),
    	format("\e[1m\e[34m\e[47m     / \\ | |  __  ||           \e[0m\n", []),
    	format("\e[1m\e[34m\e[47m    |   || | |_ | =====        \e[0m\n", []),
    	format("\e[1m\e[34m\e[47m    | | || |__| | ||           \e[0m\n", []),
    	format("\e[1m\e[34m\e[47m    |_/\\ \\_____|  =====        \e[0m\n", []).


draw_option(Number, Description) :-
    	format("\e[1m\e[34m\e[47m            [~d] ~w            \e[0m\n", [Number, Description]).

draw_message(Description) :-
    	format("\e[1m\e[34m\e[47m             ~w            \e[0m\n", [Description]).


draw_initial_menu :-
	draw_logo,
	nl,
	draw_option(1, 'Start Game'),
	draw_option(0, 'Exit').

draw_choose_player_type_menu :-
	draw_logo,
	nl,
	draw_option(4, 'Human vs Human'),
	draw_option(3, 'Human vs Computer'),
	draw_option(2, 'Computer vs Computer'),
	draw_option(1, 'Back'),
	draw_option(0, 'Exit').

draw_choose_difficulty_menu(Message) :-
	draw_logo,
	nl,
	draw_message(Message),
	draw_option(3, 'Easy'),
	draw_option(2, 'Hard'),
	draw_option(1, 'Back'),
	draw_option(0, 'Exit').

draw_choose_board_size_menu :-
	draw_logo,
	nl,
	draw_message('Please indicate the board size').
	
	