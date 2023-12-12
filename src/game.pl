% Checks for the enemy of a player
% enemy_of(+Player,-Enemy)
enemy_of(b,y).
enemy_of(y, b).



% Validates the input of the player in terms of moves
% validate_input(+ListOfMoves,+Size,+LetterInput,+NumberInput,-LetterInputRes,-NumberInputRes)
validate_input(ListOfMoves, _, LetterInput, NumberInput, LetterInput, NumberInput):-
	member(LetterInput-NumberInput, ListOfMoves),
	!.

verify_input(ListOfMoves, Size, _, _, LetterInputRes, NumberInputRes):-
	draw_message('Please submit a valid position!'),
	nl,
	read_player(Size, LetterInput1, NumberInput1),
	verify_input(ListOfMoves, Size, LetterInput1, NumberInput1, LetterInputRes, NumberInputRes).


% Checks the available moves of a player
% valid_moves(+GameState,+Player,-ListOfMoves)
valid_moves(GameState-add,(CurrPlayer-_)-_,ListOfValidPieces-ListOfValidPositions):-
	!,
	enemy_of(CurrPlayer, EnemyColor),
    	get_pieces_by_color(GameState, o, EmptyPieces-EmptyPositions),
    	get_pieces_by_color(GameState, CurrPlayer, CurrPlayerPieces-CurrPlayerPositions),
	get_pieces_by_color(GameState, EnemyColor, EnemyPlayerPieces-EnemyPlayerPositions),
	get_pieces_with_enemy_neighbours(CurrPlayerPieces-CurrPlayerPositions,EnemyPlayerPieces-EnemyPlayerPositions, CurrPlayerPiecesWithNeighbours-CurrPlayerPositionsWithNeighbours),
    	append(EmptyPositions, CurrPlayerPositionsWithNeighbours, ListOfValidPositions),
	append(EmptyPieces, CurrPlayerPiecesWithNeighbours, ListOfValidPieces).

valid_moves(GameState-move, (CurrPlayer-Height)-(Letter-Number), ListOfValidPieces-ListOfValidPositions):-
	enemy_of(CurrPlayer, EnemyColor),
	get_pieces_by_color(GameState, EnemyColor, EnemyPieces-EnemyPositions),
	get_neighbour_pieces(EnemyPieces-EnemyPositions, Letter-Number, NeighbourPieces-NeighbourPositions),
	get_pieces_by_height(NeighbourPieces-NeighbourPositions, Height, ListOfValidPieces-ListOfValidPositions).



% Asks input for a player and checks for its action
% generate_input(+Size,+GameState,+Player,-LetterInput,-NumberInput,+PlayerType,-NewGameState)
generate_input(Size, GameState-(_-ListOfValidPositions), Player, Letter, Number, human, NewGameState-add):-
	read_player(Size, Letter, Number),
	move((GameState-ListOfValidPositions)-(Player-human), _-(Number-Letter), NewGameState-add).

% Generates input for AI and checks for its action
% generate_input(+Size,+GameState,+Player,+LetterInput,-NumberInput,+PlayerType,-NewGameState)
generate_input(_, GameState-(ListOfValidPieces-ListOfValidPositions), Player, Letter, Number, easy, NewGameState-add):-
	choose_move(ListOfValidPieces-ListOfValidPositions, Player, 1, _-(Letter-Number)),
	move((GameState-ListOfValidPositions)-(Player-easy), _-(Number-Letter), NewGameState-add).


generate_input(Size, GameState-(_-ListOfValidPositions), Player-_, CurrLetter-Letter, CurrNumber-Number, human, NewGameState-move):-
	read_player(Size, Letter, Number),
	move((GameState-ListOfValidPositions)-(Player-human), (CurrNumber-CurrLetter)-(Number-Letter), NewGameState-move). 

generate_input(_, GameState-ListOfPositions, Color-Height, CurrLetter-Letter, CurrNumber-Number, easy, NewGameState-move):-
	choose_move(ListOfPositions, 1, (Color-Height)-(CurrLetter-CurrNumber), _-(Letter-Number)),
	move((GameState-_)-(Color-easy), (CurrNumber-CurrLetter)-(Number-Letter), NewGameState-move). 



generate_input(_, GameState-ListOfMoves, Player, Letter, Number, hard, NewGameState-_):-
	choose_move(GameState-ListOfMoves, Player, 2, (Color-Height)-(Letter-Number)),
	make_hard_move(GameState, Player, (Color-Height)-(Letter-Number), NewGameState).

% Makes AI move
% make_hard_move(+GameState,+Player,+LetterInput,-NewGameState)
make_hard_move(GameState, Player, (Player-Height)-(Letter-Number), NewGameState):-
	valid_moves(GameState-move, (Player-Height)-(Letter-Number), ListOfMoves),
	choose_move(GameState-ListOfMoves, 2, (Player-Height)-(Letter-Number), _-(NextLetter-NextNumber)),
	move((GameState-_)-_, (Number-Letter)-(NextNumber-NextLetter), NewGameState-move).

make_hard_move(GameState, Player, _-(Letter-Number), NewGameState):-
	move((GameState-_)-(Player-hard), _-(Number-Letter), NewGameState-add).

% Manages the gameplay
% game(+CurrPlayerType,+NextPlayerType,+MoveCount,+GameState,-Winner)
game(human, NextPlayer, MoveCount, GameState, o) :- 
	display_game(GameState),
	nl,
	print_player_color(MoveCount),
	nl,
	turn(GameState, MoveCount, human, NewGameState),
	MoveCount1 is MoveCount+1,
	clear_screen,
	game_over(NewGameState, Winner),
	game(NextPlayer, human, MoveCount1, NewGameState, Winner).

game(CurrPlayerType, NextPlayerType, MoveCount, GameState, o) :- 
	display_game(GameState),
	nl,
	format("Please type enter to continue\n\n", []),
	await_enter,
	clear_screen,
	turn(GameState, MoveCount, CurrPlayerType, NewGameState),
	MoveCount1 is MoveCount+1,
	game_over(NewGameState, Winner),
	game(NextPlayerType, CurrPlayerType, MoveCount1, NewGameState, Winner).


game(CurrPlayerType, NextPlayerType, MoveCount, GameState, y) :- 
	display_game(GameState),
    	draw_endgame_menu(y, MoveCount),
    	read_number_input(0, 1, Result),
    	menu_endgame_input(Result, Event),
    	menu_state(Event, GameState, CurrPlayerType, NextPlayerType, MoveCount),
    	nl.

game(CurrPlayerType, NextPlayerType, MoveCount, GameState, b):-
	display_game(GameState),
    	draw_endgame_menu(b, MoveCount),
    	read_number_input(0, 1, Result),
    	menu_endgame_input(Result, Event),
   	menu_state(Event, GameState, CurrPlayerType, NextPlayerType, MoveCount),
    	nl.

% Manages a players turn
% turn(+GameState,+MoveCount,+PlayerType,-NewGameState)
turn(GameState, MoveCount, PlayerType, NewGameState):-
	MoveCount mod 2 =:= 0,
	!,
	length(GameState, Size),
	valid_moves(GameState-add, (b-_)-_, ListOfValidPieces-ListOfValidPositions),
	generate_input(Size, GameState-(ListOfValidPieces-ListOfValidPositions), b, _, _, PlayerType, NewGameState-add).	

	

turn(GameState, _, PlayerType, NewGameState):-
	length(GameState, Size),
	valid_moves(GameState-add, (y-_)-_, ListOfValidPieces-ListOfValidPositions),
	generate_input(Size, GameState-(ListOfValidPieces-ListOfValidPositions), y, _, _, PlayerType, NewGameState-add).

% Responsible for making a move
% move(+GameState,+Move,-NewGameState)
move((GameState-ListOfValidPositions)-(Player-PlayerType), _-(X-Y), NewGameState-add):-
	member(Y-X, ListOfValidPositions),
	!,
	length(GameState, Size),
	execute_move(GameState, Y-X, Color-Height, Player, NewGameState1),
	make_another_move(GameState, Size, Color-Height, Y-X, NewGameState1, NewGameState, PlayerType).

move((GameState-ListOfValidPositions)-_, (PrevX-PrevY)-(X-Y), NewGameState-move):-
	member(Y-X, ListOfValidPositions),
	!,
	move_piece(GameState, (PrevX-PrevY)-(X-Y), NewGameState).
	
move((GameState-ListOfValidPositions)-(Player-PlayerType), (PrevNumber-PrevLetter)-_, NewGameState-TypeOfMove):-
	draw_message('Please submit a valid position!'),
	nl,
	length(GameState, Size),
	read_player(Size, LetterInput, NumberInput),
	move((GameState-ListOfValidPositions)-(Player-PlayerType), (PrevNumber-PrevLetter)-(NumberInput-LetterInput), NewGameState-TypeOfMove).



% Moves a piece
% move_piece(+GameState,+Coordinates,-NewGameState)
move_piece(GameState, Coordinates, NewGameState):-
	length(GameState, Size),
	loop_row_move(GameState, Coordinates, Size, NewGameState).


% Adds a piece to the board
% execute_move(+GameState,+Coordinates,-NewGameState)
execute_move(GameState, Letter-Number, Color-Height, Player, NewGameState):-
	length(GameState, Size),
	find_row(GameState, Letter-Number, 0, Size, Player, NewGameState, Color-Height).

% Responsible for executing the second input when asked where to move the piece
% make_another_move(+GameState,+Size,+Color-Height,+CurrLetter-CurrNumber,-NewGameState,+PlayerType)
make_another_move(_, _, o-_, _-_, NewGameState, NewGameState, _):-
	!.


make_another_move(GameState, Size, Color-Height, CurrLetter-CurrNumber, _, NewGameState, human):-
	format("Choose which piece to move to\n", []),
	valid_moves(GameState-move, (Color-Height)-(CurrLetter-CurrNumber), _-ListOfValidPositions),
	generate_input(Size, GameState-(_-ListOfValidPositions), Color-Height, CurrLetter-_, CurrNumber-_, human, NewGameState-move).
	

make_another_move(GameState, Size, Color-Height, CurrLetter-CurrNumber, _, NewGameState, easy):-
	valid_moves(GameState-move, (Color-Height)-(CurrLetter-CurrNumber), ListOfMoves),
	generate_input(Size, GameState-ListOfMoves, Color-Height, CurrLetter-_, CurrNumber-_, easy, NewGameState-move). 


make_another_move(_, _, _-_, _-_, _, _, hard).
	

	





        



	
	
	
	





	
	




	