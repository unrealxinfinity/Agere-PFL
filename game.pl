enemy_of(b,y).
enemy_of(y, b).




validate_input(ListOfMoves, _, LetterInput, NumberInput, LetterInput, NumberInput):-
	member(LetterInput-NumberInput, ListOfMoves),
	!.

verify_input(ListOfMoves, Size, _, _, LetterInputRes, NumberInputRes):-
	draw_message('Please submit a valid position!'),
	nl,
	read_player(Size, LetterInput1, NumberInput1),
	verify_input(ListOfMoves, Size, LetterInput1, NumberInput1, LetterInputRes, NumberInputRes).



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




generate_input(Size, _, _, Letter, Number, human):-
	read_player(Size, Letter, Number).

generate_input(_, GameState, Player, Letter, Number, easy):-
	choose_move(GameState, Player, 1, _-(Letter-Number)).

generate_input(_, GameState, Player, Letter, Number, hard):-
	choose_move(GameState, Player, 2, _-(Letter-Number)).

generate_input(_, GameState, Color-Height, CurrLetter, CurrNumber, Letter, Number, easy):-
	choose_move(GameState, 1, (Color-Height)-(CurrLetter-CurrNumber), _-(Letter-Number)). 





game(human, NextPlayer, MoveCount, GameState, o) :- 
	display_game(GameState),
	turn(GameState, MoveCount, human, NewGameState),
	MoveCount1 is MoveCount+1,
	game_over(NewGameState, Winner),
	game(NextPlayer, human, MoveCount1, NewGameState, Winner).

game(CurrPlayerType, NextPlayerType, MoveCount, GameState, o) :- 
	display_game(GameState),
	nl,
	draw_message('Please type enter to continue'),
	nl,
	await_enter,
	turn(GameState, MoveCount, CurrPlayerType, NewGameState),
	MoveCount1 is MoveCount+1,
	game_over(NewGameState, Winner),
	game(NextPlayerType, CurrPlayerType, MoveCount1, NewGameState, Winner).


game(_, _, _, GameState, y) :- 
	display_game(GameState),
	write('Yellow won'),
	nl.

game(_, _, _, GameState, b) :- 
	display_game(GameState),
	write('Blue won'),
	nl.


turn(GameState, MoveCount, PlayerType, NewGameState):-
	MoveCount mod 2 =:= 0,
	!,
	length(GameState, Size),
	valid_moves(GameState-add, (b-_)-_, _-ListOfValidPositions),
	display_action_message(PlayerType),
	generate_input(Size, GameState, b, Letter, Number, PlayerType),
	move((GameState-ListOfValidPositions)-(b-PlayerType), _-(Number-Letter), NewGameState-add).
	

	

turn(GameState, _, PlayerType, NewGameState):-
	length(GameState, Size),
	valid_moves(GameState-add, (y-_)-_, _-ListOfValidPositions),
	generate_input(Size, GameState, y, Letter, Number, PlayerType),
	move((GameState-ListOfValidPositions)-(y-PlayerType), _-(Number-Letter), NewGameState-add).


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




move_piece(GameState, Coordinates, NewGameState):-
	length(GameState, Size),
	loop_row_move(GameState, Coordinates, Size, NewGameState).




execute_move(GameState, Letter-Number, Color-Height, Player, NewGameState):-
	length(GameState, Size),
	find_row(GameState, Letter-Number, 0, Size, Player, NewGameState, Color-Height).

make_another_move(_, _, o-_, _-_, NewGameState, NewGameState, _):-
	!.

make_another_move(GameState, Size, Color-Height, CurrLetter-CurrNumber, _, NewGameState, human):-
	draw_message('Choose which piece to move to'),
	nl,
	valid_moves(GameState-move, (Color-Height)-(CurrLetter-CurrNumber), _-ListOfValidPositions),
	generate_input(Size, GameState, Color, Letter, Number, human),
	move((GameState-ListOfValidPositions)-(Color-human), (CurrNumber-CurrLetter)-(Number-Letter), NewGameState-move). 
	

make_another_move(GameState, Size, Color-Height, CurrLetter-CurrNumber, _, NewGameState, easy):-
	generate_input(Size, GameState, Color-Height, CurrLetter, CurrNumber, Letter, Number, easy),
	move((GameState-_)-(Color-easy), (CurrNumber-CurrLetter)-(Number-Letter), NewGameState-move). 


make_another_move(_, _, _-_, _-_, _, _, hard).
	

	





        



	
	
	
	





	
	




	