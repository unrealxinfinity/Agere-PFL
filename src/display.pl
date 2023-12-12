% Makes translation of color to board symbols
% translate(+Piece,-Symbol)
translate(o, ' ').
translate(b, '*').
translate(y, '-').
% Writes a certain number of spaces
write_spaces(N) :-
    format('~*|', [N]).

% Clears the screen by writing new lines
% clear_screen/0
clear_screen :- write('\33\[2J').

% Draws a piece
% draw_piece(+Piece)
draw_piece(Piece):-
	write(Piece).
% Shows the row letter for the board
% draw_letter(+Size)
draw_letter(Size):-
	LetterCode is 65+Size,
    	char_code(Letter, LetterCode),
    	write(Letter).
% Draws a color in the board
% draw_color(+Color,+Size)
draw_color(_, 0).

draw_color(Color, Size):-
	Size > 0,
	write(Color),
	Size1 is Size - 1,
	draw_color(Color, Size1).

% Draws the numbers in the board
% draw_numbers(+Size,+Counter,+Offset,+FontSize)
draw_numbers(Size, Size, _, _).


draw_numbers(Size, Counter, Offset, FontSize):-
	write_spaces(Offset),
	Counter =< Size,
	Number is Counter + 1,
	Offset1 is Offset+FontSize,
	write(Number),
	draw_numbers(Size, Number, Offset1, FontSize).

% Draws the board position borders
% draw_row_middle(+Row,+Length,+FontSize)
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


% Draws the board position borders
% draw_row_middle_first(+Row,+Length,+FontSize)
draw_row_middle_first([Piece-_|List], Length, FontSize, _):-
	Length =\= ceiling((FontSize/2)/2),
	FontSize5 is ceiling((FontSize/2)),
	\+compare(Length, FontSize5),
	!,
	write('  |'),
	translate(Piece, Color),
	FontSize1 is FontSize-1,
	draw_color(Color, FontSize),
	draw_row_middle(List, Length, FontSize1).

draw_row_middle_first([Piece-0|List], Length, FontSize, Size):-
	FontSize4 is ceiling((FontSize/2)),
	\+compare(Length, FontSize4),
	draw_letter(Size),
	write(' |'),
	!,
	translate(Piece, Color),
	FontSize1 is FontSize-1,
	draw_color(Color, FontSize),
	draw_row_middle(List, Length, FontSize1).

draw_row_middle_first([Piece-Height|List], Length, FontSize, Size):-
	FontSize4 is ceiling((FontSize/2)),
	\+compare(Length, FontSize4),
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

% Draws the board position corners
% draw_row_corners(+Row,+PrevRow,+FontSizeTop,+FontSizeBottom)
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

% Draws the board position corners
% draw_last_row_bottom(+Row,+FontSizeBottom,+FontSizeTop,+Size)
draw_last_row_bottom([], _, _, _).

draw_last_row_bottom([Piece-_|List], 0, FontSizeTop, Size):-
	!,
	write('\\'),
	translate(Piece, Color),
	draw_color(Color, FontSizeBottom),
	write('/'),
	draw_color(' ', FontSizeTop),
	Size1 is Size+2,
	draw_last_row_bottom(List, FontSizeBottom, FontSizeTop, Size1).

draw_last_row_bottom([Piece-_|List], FontSizeBottom, FontSizeTop, Size):-
	write('\\'),
	translate(Piece, Color),
	draw_color(Color, FontSizeBottom),
	write('/'),
	draw_color(' ', FontSizeTop),
	Size1 is Size+2,
	draw_last_row_bottom(List, FontSizeBottom, FontSizeTop, Size1).

% Draws the board 
% display_game(+GameState)
display_game(GameState):-
	length(GameState, Size),
	nl,
	display_rows(GameState, _, Size, Size, 3, 0).

% Draws the board rows
% display_rows(+GameState,+PrevRow,+Size,+Size2,+FontSize,+LetterCount)
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

% Draws the board rows
% display_row_middle(+Row,+Length,+Offset,+FontSize,+Size)
display_row_middle(_, 0, _, _, _).

display_row_middle(Row, Length, Offset, FontSize, Size) :-
	Length > 0,
	draw_row_middle_first(Row, Length, FontSize, Size),
	nl,
	write_spaces(Offset),
	Length1 is Length-1,
	display_row_middle(Row, Length1, Offset, FontSize, Size).

% Draws the board row corners
% display_row_corners(+Row,+PrevRow,+Length,+Offset,+FontSizeTop,+FontSizeBottom)
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
	draw_last_row_bottom(Row, FontSizeBottom, FontSizeTop, 0),
	nl,
	FontSizeBottom1 is FontSizeBottom - 2,
	FontSizeTop1 is FontSizeTop+2,
	Offset1 is Offset+1,
	write_spaces(Offset1),
	Length1 is Length - 1,
	display_last_row_bottom(Row, Length1, Offset1, FontSizeBottom1, FontSizeTop1).

	
	




% Draws the logo of the game 
% draw_logo/0
draw_logo :-
    format(" ______     ______     ______     ______     ______   \n", []),
    format("/\\  __ \\   /\\  ___\\   /\\  ___\\   /\\  == \\   /\\  ___\\  \n", []),
    format("\\ \\  __ \\  \\ \\ \\__ \\  \\ \\  __\\   \\ \\  __<   \\ \\  __\\  \n", []),
    format(" \\ \\_\\ \\_\\  \\ \\_____\\  \\ \\_____\\  \\ \\_\\ \\_\\  \\ \\_____\\ \n", []),
    format("  \\/_/\\/_/   \\/_____/   \\/_____/   \\/_/ /_/   \\/_____/ \n", []).

% Displays the menu option
% draw_option(+Number,+Description)
draw_option(Number, Description) :-
    	format("\e[1m\e[34m\e[47m            [~d] ~w            \e[0m\n", [Number, Description]).
% Displays the menu message	
% draw_message(+Description)
draw_message(Description) :-
    	format("\e[1m\e[34m\e[47m             ~w            \e[0m\n", [Description]).

% Displays action message
% display_action_message/0
display_action_message :-
	nl,
	!,
	format("Please choose a board space!\n\n", []).

% Displays the player turn
% display_player_turn(+Player)
print_player_color(MoveCount):-
	MoveCount mod 2 =:= 0,
	format("It\'s the blue player\'s turn\n", []).

print_player_color(MoveCount):-
	MoveCount mod 2 =:= 1,
	format("It\'s the yellow player\'s turn\n", []).


% Displays the initial menu 
% draw_initial_menu/0
draw_initial_menu :-
	draw_logo,
	nl,
	draw_option(1, 'Start Game'),
	draw_option(0, 'Exit').

% Displays the mode menu
% draw_choose_player_type_menu/0
draw_choose_player_type_menu :-
	draw_logo,
	nl,
	draw_option(4, 'Human vs Human'),
	draw_option(3, 'Human vs Computer'),
	draw_option(2, 'Computer vs Computer'),
	draw_option(1, 'Back'),
	draw_option(0, 'Exit').



% Displays the difficulty menu
% draw_choose_difficulty_menu/0
draw_choose_difficulty_menu(Message) :-
	draw_logo,
	nl,
	draw_message(Message),
	draw_option(3, 'Easy'),
	draw_option(2, 'Hard'),
	draw_option(1, 'Back'),
	draw_option(0, 'Exit').


% Displays the choose starting player menu
% draw_choose_starting_player/0
draw_choose_starting_player :-
	draw_logo,
	nl,
	draw_message('Do you wish to go first?'),
	draw_option(3, 'Yes'),
	draw_option(2, 'No'),
	draw_option(1, 'Back'),
	draw_option(0, 'Exit').

% Displays the choose board size menu
% draw_choose_board_size_menu/0
draw_choose_board_size_menu :-
	draw_logo,
	nl,
	draw_message('Please indicate the board size').

% Displays game over message and player who won
% draw_game_over(+Player)
draw_game_over(y):-
    format("         _ _                      \n", []),
    format(" _ _ ___| | |___ _ _ _    _ _ _ ___ ___ \n", []),
    format("| | | -_| | | . | | | |  | | | | . |   |\n", []),
    format("|_  |___|_|_|___|_____|  |_____|___|_|_|\n", []),
    format("|___|                             \n", []).

                                                                  
draw_game_over(b):-
    format("\n", []),
    format(" _   _                          \n", []),
    format("| |_| |_ _ ___    _ _ _ ___ ___ \n", []),
    format("| . | | | | -_|  | | | | . |   |\n", []),
    format("|___|_|___|___|  |_____|___|_|_|\n", []).



% Displays the menu after game ends
% draw_endgame_menu(+Player,+MoveCount)
draw_endgame_menu(y, MoveCount):-
	MoveCount1 is ceiling(MoveCount/2),
    	nl,
	draw_game_over(y),
	nl,
	format("   Yellow Player won in ~d Moves",[MoveCount1]),
	nl,
    	draw_option(1, 'Play Again'),
    	draw_option(0, 'Back to main menu').
draw_endgame_menu(b, MoveCount):-
	MoveCount1 is ceiling(MoveCount/2),	
    	nl,
	draw_game_over(b),
	nl,
	format("   Blue Player won in ~d Moves\n",[MoveCount1]),
	nl,
    	draw_option(1, 'Play Again'),
    	draw_option(0, 'Back to main menu').

	
	