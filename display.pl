translate(o, ' ').
translate(b, '*').
translate(y, '-').

write_spaces(N) :-
    format('~*|', [N]).


clear_screen :- write('\33\[2J').


draw_piece(Piece):-
	write(Piece).

draw_letter(Size):-
	LetterCode is 65+Size,
    	char_code(Letter, LetterCode),
    	write(Letter).

draw_color(_, 0).

draw_color(Color, Size):-
	Size > 0,
	write(Color),
	Size1 is Size - 1,
	draw_color(Color, Size1).

draw_numbers(Size, Size, _, _).


draw_numbers(Size, Counter, Offset, FontSize):-
	write_spaces(Offset),
	Counter =< Size,
	Number is Counter + 1,
	Offset1 is Offset+FontSize,
	write(Number),
	draw_numbers(Size, Number, Offset1, FontSize).


draw_row_middle([], _, _):- 
	write('|').


draw_row_middle([Piece-0|List], Length, FontSize):-
	!,
	write('|'),
	translate(Piece, Color),
	draw_color(Color, FontSize),
    	draw_row_middle(List, Length, FontSize).
	

draw_row_middle([Piece-_|List], Length, FontSize):-
	Length =\= ceiling((FontSize/2)/2),
	!,
	write('|'),
	translate(Piece, Color),
	draw_color(Color, FontSize),
    	draw_row_middle(List, Length, FontSize).



draw_row_middle([Piece-Height|List], Length, FontSize):-
	write('|'),
	translate(Piece, Color),
	FontSize1 is ceiling((FontSize/2))-1,
	draw_color(Color, FontSize1),
	write(Height),
	draw_color(Color, FontSize1), 
    	draw_row_middle(List, Length, FontSize).



draw_row_middle_first([Piece-_|List], Length, FontSize, _):-
	Length =\= ceiling((FontSize/2)/2),
	Length =\= FontSize/2,
	!,
	write('  |'),
	translate(Piece, Color),
	FontSize1 is FontSize-1,
	draw_color(Color, FontSize),
	draw_row_middle(List, Length, FontSize1).

draw_row_middle_first([Piece-0|List], Length, FontSize, Size):-
	Length =\= (FontSize/2),
	draw_letter(Size),
	write(' |'),
	!,
	translate(Piece, Color),
	FontSize1 is FontSize-1,
	draw_color(Color, FontSize),
	draw_row_middle(List, Length, FontSize1).

draw_row_middle_first([Piece-Height|List], Length, FontSize, Size):-
	Length =\= (FontSize/2),
	draw_letter(Size),
	write(' |'),
	!,
	translate(Piece, Color),
	FontSize2 is ceiling(FontSize/2)-1,
	draw_color(Color, FontSize2),
	write(Height),
	FontSize3 is FontSize2+1,
	draw_color(Color, FontSize3),
	FontSize1 is FontSize-1,
	draw_row_middle(List, Length, FontSize1).

draw_row_middle_first([Piece-_|List], Length, FontSize, _):-
	write('|'),
	translate(Piece, Color),
	FontSize1 is FontSize-1,
	draw_color(Color, FontSize),
	draw_row_middle(List, Length, FontSize1).

draw_row_corners([], _, _, _).
	

draw_row_corners([Piece-_|List], [PrevPiece-_|PrevList], FontSizeTop, FontSizeBottom):-
	translate(PrevPiece, TopColor),
	draw_color(TopColor, FontSizeBottom),
	write('/'),
	translate(Piece, BottomColor),
	draw_color(BottomColor, FontSizeTop),
	write('\\'),
    	draw_row_corners(List, PrevList, FontSizeTop, FontSizeBottom).


draw_row_corners_first([Piece-_|List], PrevRow, FontSizeTop, FontSizeBottom):-
	write('/'),
	translate(Piece, Color),
	draw_color(Color, FontSizeTop),
	write('\\'),
	draw_row_corners(List, PrevRow, FontSizeTop, FontSizeBottom).

draw_last_row_bottom([], _, _).

draw_last_row_bottom([Piece-_|List], FontSizeBottom, FontSizeTop):-
	write('\\'),
	translate(Piece, Color),
	draw_color(Color, FontSizeBottom),
	write('/'),
	draw_color(' ', FontSizeTop),
	draw_last_row_bottom(List, FontSizeBottom, FontSizeTop).

display_game(GameState):-
	length(GameState, Size),
	nl,
	display_rows(GameState, _, Size, Size, 3, 0).

display_rows([], PrevRow, Size1, Size2, FontSize, _):-
	FontSizeBottom is FontSize*2-2,
	Offset is Size1*FontSize+5,
	write_spaces(Offset),
	display_last_row_bottom(PrevRow, FontSize, Offset, FontSizeBottom, 0),
	Size is Size2 + Size2-1,
	Offset1 is Offset + FontSize-1,
	draw_numbers(Size, 0, Offset1, FontSize),
	nl.

display_rows([Row | List], PrevRow, Size, Size2, FontSize, LetterCount) :-
	Offset is (Size-1)*FontSize,
	Offset1 is Offset+2,
	FontSize2 is FontSize * 2,
	Offset2 is Offset+5 + FontSize-1,
	write_spaces(Offset2),
	FontSizeBottom is FontSize2-2,
	display_row_corners(Row, PrevRow, FontSize, Offset2, 0, FontSizeBottom),
    	display_row_middle(Row, FontSize, Offset1, FontSize2, LetterCount),
    	Size1 is Size-1,
	LetterCount1 is LetterCount+1,
    	display_rows(List, Row, Size1, Size2, FontSize, LetterCount1).


display_row_middle(_, 0, _, _, _).

display_row_middle(Row, Length, Offset, FontSize, Size) :-
	Length > 0,
	draw_row_middle_first(Row, Length, FontSize, Size),
	nl,
	write_spaces(Offset),
	Length1 is Length-1,
	display_row_middle(Row, Length1, Offset, FontSize, Size).

display_row_corners(_, _, 0, _, _, _).

display_row_corners(Row, PrevRow, Length, Offset, FontSizeTop, FontSizeBottom) :-
	Length > 0,
	draw_row_corners_first(Row, PrevRow, FontSizeTop, FontSizeBottom),
	nl,
	FontSizeTop1 is FontSizeTop+2,
	FontSizeBottom1 is FontSizeBottom-2,
	Offset1 is Offset-1,
	write_spaces(Offset1),
	Length1 is Length-1,
	display_row_corners(Row, PrevRow, Length1, Offset1, FontSizeTop1, FontSizeBottom1).

display_last_row_bottom(_, 0, _, _, _).

display_last_row_bottom(Row, Length, Offset, FontSizeBottom, FontSizeTop):-
	Length > 0,
	draw_last_row_bottom(Row, FontSizeBottom, FontSizeTop),
	nl,
	FontSizeBottom1 is FontSizeBottom - 2,
	FontSizeTop1 is FontSizeTop+2,
	Offset1 is Offset+1,
	write_spaces(Offset1),
	Length1 is Length - 1,
	display_last_row_bottom(Row, Length1, Offset1, FontSizeBottom1, FontSizeTop1).

	
	





draw_logo :-
    	format("\e[1m\e[34m\e[47m      _   / ____ ________  ___           \e[0m\n", []),
    	format("\e[1m\e[34m\e[47m     / \\ | |  __ | _____/ /   \\        \e[0m\n", []),
    	format("\e[1m\e[34m\e[47m    |   || | |_| | |__/   |_ /           \e[0m\n", []),
    	format("\e[1m\e[34m\e[47m    | | || |__|| | |____  |  \\ |        \e[0m\n", []),
    	format("\e[1m\e[34m\e[47m    |_/\\ \\_____| |_____/  |_\\ \\ \\   \e[0m\n", []).


draw_option(Number, Description) :-
    	format("\e[1m\e[34m\e[47m            [~d] ~w            \e[0m\n", [Number, Description]).

draw_message(Description) :-
    	format("\e[1m\e[34m\e[47m             ~w            \e[0m\n", [Description]).


display_action_message(human):-
	nl,
	!,
	draw_message('Please choose a board space!\n\n').

display_action_message(_):-
	nl,
	draw_message('The computer chose the following move!\n\n').



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
	
	