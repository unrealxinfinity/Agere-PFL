% Gets move from a given list by choosing an index
% get_move(+MoveList,+Index,CurrIndex,ReturnPiece,ReturnPosition)
get_move([_|Pieces]-[_|Positions],Chosen,Index,ResPiece,ResPosition):-
	Index < Chosen,
	!,
	Index1 is Index + 1,
	get_move(Pieces-Positions,Chosen,Index1,ResPiece,ResPosition).
	
get_move([Piece|_]-[Position|_],Chosen,Chosen,Piece,Position).


% Chooses a random index to get a move from the list of moves
% get_random_move(+MoveList,-Move)
get_random_move(Pieces-Positions,ChosenPiece-ChosenPosition):-
	length(Pieces,Size),
	Size > 0,
	!,
	random(0,Size,Chosen),
	get_move(Pieces-Positions,Chosen,0,ChosenPiece,ChosenPosition).
	
get_random_move(_,[]-[]).
	
	
% There are 2 choose_moves for each AI because we need to distinguish between choosing for position selection or choosing for moving a piece.
	
% Chooses move for easy AI using random
% choose_move(+GameState,+Level,+Player,-Move)
choose_move(GameState, 1, _,FinalMove):-
	!,
	get_random_move(GameState,FinalMove).

	

choose_move(GameState,_,1,Move):-
	!,
        get_random_move(GameState,Move).

% Chooses move for hard AI
% choose_move(+PossibleMoves,+Level,+PlayerAndPosition,-Move)
choose_move(GameState-ListOfMoves, 2, (Player-_)-Position,FinalMove):-
	!,
	value((GameState-Position)-ListOfMoves, Player, Value),
	get_highest_value(Value, ListOfMoves, 0, []-[], Moves, _),
	get_random_move(Moves,FinalMove).
	
% Either selects a move for hard AI
% choose_move(+PossibleMoves,+Player,+Level,-Move)
choose_move(GameState-ListOfMoves,Player,2,Move):-
	!,
        value((GameState-_)-ListOfMoves, Player, Value),
	get_highest_value(Value, ListOfMoves, 0, []-[], Moves, _),
	get_random_move(Moves, Move).


get_highest_value([], []-[], Max, Moves, Moves, Max).

% Evaluates the possible moves and their respective values to get the highest valued move(s) to play
% get_highest_value(+Values,+Moves,?Max,?MoveAcc,-FilteredMoves,-MaxValue)
get_highest_value([Value|Values], [Color-Height|Pieces]-[Row-Column|Positions], Max, _, Moves, MaxValue):-
	Value > Max,
	get_highest_value(Values, Pieces-Positions, Value, [Color-Height]-[Row-Column], Moves, MaxValue).

get_highest_value([Max|Values], [Piece|Pieces]-[Position|Positions], Max, PiecesAcc-PositionsAcc, Moves, MaxValue):-
	append(PiecesAcc, [Piece], PiecesAcc1),
	append(PositionsAcc, [Position], PositionsAcc1),
	get_highest_value(Values, Pieces-Positions, Max, PiecesAcc1-PositionsAcc1, Moves, MaxValue).

get_highest_value([_|Values], [_|Pieces]-[_|Positions], Max, Acc, Moves, MaxValue):-
	get_highest_value(Values, Pieces-Positions, Max, Acc, Moves, MaxValue).

% Resets the priority values of each position to be evaluated later
% initialise_value(?Values,+Size)
initialise_value([], 0).

initialise_value([0|Values], Size):-
	Size1 is Size-1,
	initialise_value(Values, Size1).

% Checks if enemy has won the game by analyzing many conditions
% check_if_enemy_won(+GameState,+Size,+Player,+Path,+EnemyHeightsPlayerPos)
check_if_enemy_won(GameState, Size, Player, Path-Moves, (EnemyPositionsHeight-EnemyPlayerPositions)-(PlayerPieces-PlayerPositions)):-
	valid_moves(GameState-add, (Player-_)-_,ListOfEnemyPieces-ListOfEnemyPositions),
	get_pieces_by_color(GameState, Player, EnemyPlayerPieces-EnemyPlayerPositions),
	get_pieces_by_height(EnemyPlayerPieces-EnemyPlayerPositions, 1, _-EnemyPositionsHeight),
	get_pieces_by_height(PlayerPieces-PlayerPositions, 1, _-PlayerPositionsHeight),
	length(ListOfEnemyPositions, EnemySize),
	initialise_value(Value1, EnemySize),
	assign_value(GameState, ListOfEnemyPieces-ListOfEnemyPositions, Player, Value-Value1, (EnemyPlayerPieces-EnemyPlayerPositions)-(PlayerPositions-PlayerPositionsHeight), Size, _, []-([]-[])),
	get_highest_value(Value, ListOfEnemyPieces-ListOfEnemyPositions, 0, []-[], Moves, MaxValue),
	!,
	MaxValue >= 1000,
	get_random_move(Moves, (Color-Height)-(Row-Column)),
	check_type_of_move(Color-Height, Row-Column, EnemyPlayerPositions-(PlayerPositions-PlayerPieces), Size, Path, GameState-EnemyPlayerPieces).

% Checks the type of move AI has to make accordint to some conditions
% check_type_of_move(+Piece,+Position,+EnemyAndPlayer,+Size,-Path,+GameStateAndEnemy)
check_type_of_move(o-_, Row-Column, EnemyPlayerPositions-_, Size, Path, _):-
	!,
	append(EnemyPlayerPositions, [Row-Column], EnemyPlayerPositions1),
	get_pieces_at_edges(_-EnemyPlayerPositions1, _-EdgesPositions, Size),
	\+is_empty(EdgesPositions),
	send_to_bfs(EdgesPositions, EnemyPlayerPositions1, Size, [], Path).

check_type_of_move(Color-Height, Row-Column, EnemyPlayerPositions-(PlayerPositions-PlayerPieces), Size, Path, GameState-EnemyPieces):-
	valid_moves(GameState-move, (Color-Height)-(Row-Column), ListOfPieces-ListOfPositions),
	length(ListOfPositions, Size1),
	initialise_value(Value1, Size1),
	get_pieces_by_height(PlayerPieces-PlayerPositions, 1, _-HeightPositions),
	assign_value(GameState, ListOfPieces-ListOfPositions, Color, Value-Value1, (EnemyPieces-EnemyPlayerPositions)-(PlayerPositions-HeightPositions), Size, Row-Column, []-([]-[])),
	get_highest_value(Value, ListOfPieces-ListOfPositions, 0, []-[], Moves, _),
	get_random_move(Moves, _-(Row1-Column1)),
	remove_previous_position(EnemyPlayerPositions, Row-Column, EnemyPlayerPositions1),
	append(EnemyPlayerPositions1, [Row1-Column1], EnemyPlayerPositions1),
	get_pieces_at_edges(_-EnemyPlayerPositions1, _-EdgesPositions, Size),
	\+is_empty(EdgesPositions),
	send_to_bfs(EdgesPositions, EnemyPlayerPositions1, Size, [], Path).
% Assigns a value to each move
% value(+GameStateAndPrevPosition,+Player,-Value)	
value((GameState-PrevPosition)-(ListOfPieces-ListOfPositions), Player, Value):-
	length(GameState, Size),
	enemy_of(Player, EnemyPlayer),
	get_pieces_by_color(GameState, Player, PlayerPieces-PlayerPositions),
	check_if_enemy_won(GameState, Size, EnemyPlayer, Path-(PieceMoves-PositionMoves), (EnemyPositionsHeight-EnemyPositions)-(PlayerPieces-PlayerPositions)),
	!,
	length(ListOfPieces, ValueSize),
	initialise_value(Value1, ValueSize),
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Value-Value1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyPositionsHeight), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

value((GameState-PrevPosition)-(ListOfPieces-ListOfPositions), Player, Value):-
	length(GameState, Size),
	length(ListOfPieces, ValueSize),
	initialise_value(Value1, ValueSize),
	get_pieces_by_color(GameState, Player, PlayerPieces-PlayerPositions),
	enemy_of(Player, EnemyPlayer),
	get_pieces_by_color(GameState, EnemyPlayer, EnemyPieces-EnemyPositions),
	get_pieces_by_height(EnemyPieces-EnemyPositions, 1, _-EnemyHeightPositions),
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Value-Value1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, []-([]-[])).

assign_value(_, []-[], _, []-[],_, _, _, _).

% Assigns a value to each type of move and according to many conditions
% assign_value(+GameStateAndPrevPosition,+ListOfPiecesAndPositions,+Player,-Value,-PlayerAndEnemy,-Size,-PrevPosition,-Path)
assign_value(GameState, [o-_|ListOfPieces]-[Row-Column|ListOfPositions], Player, [Value|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	append(PlayerPositions, [Row-Column], PlayerPositions1),
	is_move_winning(Size, PlayerPositions1, Value-Value1),
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).


assign_value(GameState, [o-Height|ListOfPieces]-[Row-Column|ListOfPositions], Player, [Value|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	member(Row-Column, Path),
	append(PlayerPositions, [Row-Column], PlayerPositions1),
	append(PlayerPieces, [o-Height], PlayerPieces1),
	can_be_saved((PieceMoves-PositionMoves), PlayerPositions1-PlayerPieces1, EnemyPositions, Row-Columm, Size, Player),
	!,
	get_value_by_height(EnemyHeightPositions, Row-Column, Value2),	
	get_value_by_path(PlayerPositions, Row-Column, Value3),
	get_value_by_blocking(Row-Column, EnemyPositions-EnemyHeightPositions, Value4),
	get_value_near_high_piece(EnemyPositions-EnemyHeightPositions, Row-Column, Value5),
	Value is Value1+7000+Value3-Value2+Value4+Value5,
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

assign_value(GameState, [o-_|ListOfPieces]-[Row-Column|ListOfPositions], Player, [Value|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	get_value_by_height(EnemyHeightPositions, Row-Column, Value2),
	get_value_by_path(PlayerPositions, Row-Column, Value3),
	get_value_by_blocking(Row-Column, EnemyPositions-EnemyHeightPositions, Value4),
	get_value_near_high_piece(EnemyPositions-EnemyHeightPositions, Row-Column, Value5),
	Value is Value1+Value3-Value2+Value4+Value5,
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

assign_value(GameState, [Player-Height|ListOfPieces]-[Position|ListOfPositions], Player, [Value|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	valid_moves(GameState-move,(Player-Height)-Position, ListOfMovesPieces-ListOfMovesPositions),
	length(ListOfMovesPieces, Size1),
	initialise_value(Value3, Size1),
	assign_value(GameState, ListOfMovesPieces-ListOfMovesPositions, Player, Value2-Value3, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, Position, Path-(PieceMoves-PositionMoves)),
	get_highest_value(Value2, ListOfMovesPieces-ListOfMovesPositions, 0, []-[], _, MaxValue),
	Value is Value1+MaxValue,
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

assign_value(GameState, [Color-_|ListOfPieces]-[Row-Column|ListOfPositions], Player, [Value|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	enemy_of(Color, Player),
	remove_previous_position(PlayerPositions, PrevPosition, PlayerPositions1),
	append(PlayerPositions1, [Row-Column], PlayerPositions2),
	is_move_winning(Size, PlayerPositions2, Value-Value1),
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).




assign_value(GameState, [Color-_|ListOfPieces]-[Row-Column|ListOfPositions], Player, [Value1|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	enemy_of(Color, Player),
	remove_previous_position(EnemyPositions, Row-Column, EnemyPositions1),
	append(EnemyPositions1, [PrevPosition], EnemyPositions2),
	is_move_winning(Size, EnemyPositions2, Value2-Value1),
	\+var(Value2), 
	!,
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

assign_value(GameState, [Color-Height|ListOfPieces]-[Row-Column|ListOfPositions], Player, [Value|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	enemy_of(Color, Player),
	Height > 1,
	member(Row-Column, Path),
	Value is Value1 + 6000,
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

assign_value(GameState, [Color-1|ListOfPieces]-[Row-Column|ListOfPositions], Player, [Value|Values]-[Value1|Values1],(PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	enemy_of(Color, Player),
	member(Row-Column, Path),
	remove_previous_position(EnemyPositions, Row-Column, EnemyPositions1),
	remove_previous_piece(PlayerPositions, PlayerPieces, PrevPosition, PlayerPositions1-PlayerPieces1),
	append(PlayerPositions1, [Row-Column], PlayerPositions2),
	append(PlayerPieces1, [Player-2], PlayerPieces2),
	append(PositionMoves, [PrevPosition], PositionMoves1),
	append(PieceMoves, [o-0], PieceMoves1),
	get_neighbour_pieces(_-EnemyHeightPositions, Row-Column, _-NeighbourPositions),
	form_pieces(NeighbourPositions, Color, NeighbourPieces),
	append(PieceMoves1, NeighbourPieces, PieceMoves2),
	append(PositionMoves1, NeighbourPositions, PositionMoves2),
	can_be_saved(PieceMoves2-PositionMoves2, PlayerPieces2-PlayerPositions2, EnemyPositions1, Row-Column, Size, Player),
	Value is Value1 + 8000,
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

assign_value(GameState, [Color-1|ListOfPieces]-[_|ListOfPositions], Player, [Value|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	enemy_of(Color, Player),
	Value is Value1 + 150,
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

assign_value(GameState, [Color-Height|ListOfPieces]-[_|ListOfPositions], Player, [Value|Values]-[Value1|Values1], (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)):-
	enemy_of(Color, Player),
	Height > 1,
	Value is Value1 + 10,
	assign_value(GameState, ListOfPieces-ListOfPositions, Player, Values-Values1, (PlayerPieces-PlayerPositions)-(EnemyPositions-EnemyHeightPositions), Size, PrevPosition, Path-(PieceMoves-PositionMoves)).

% Checks if a piece can cause save the game by preventing other of winning
% can_be_saved(+PieceMovesAndPositionMoves,+PlayerPiecesAndPositions,+EnemyPositions,+PrevPosition,+Size,+Player)
can_be_saved([]-[], _, _, _, _, _).

can_be_saved([_|PieceMoves]-[Row-Column|PositionMoves], PlayerPieces-PlayerPositions, EnemyPositions, Row-Column, Size, Player):-
	!,
	can_be_saved(PieceMoves-PositionMoves, PlayerPieces-PlayerPositions, EnemyPositions, Row-Column, Size, Player).

can_be_saved([o-_|PieceMoves]-[Row1-Column1|PositionsMoves], PlayerPieces-PlayerPositions, EnemyPositions, Row-Column, Size, Player):-
	append(EnemyPositions, [Row1-Column1], EnemyPositions1),
	!,
	\+is_move_winning(Size, EnemyPositions1, _-0),
	can_be_saved(PieceMoves-PositionsMoves, PlayerPieces-PlayerPositions, EnemyPositions, Row-Column, Size, Player).

can_be_saved([EnemyPlayer-Height|PieceMoves]-[Row1-Column1|PositionsMoves], PlayerPieces-PlayerPositions, EnemyPositions, Row-Column, Size, Player):-
	enemy_of(Player, EnemyPlayer),
	!,
	get_neighbour_pieces(PlayerPieces-PlayerPositions, Row1-Column1, NeighbourPieces-NeighbourPositions),
	get_pieces_by_height(NeighbourPieces-NeighbourPositions, Height, HeightPieces-HeightPositions),
	append(PieceMoves, HeightPieces, PieceMoves1),
	append(PositionsMoves, HeightPositions, PositionsMoves1), 
	can_be_saved(PieceMoves1-PositionsMoves1, PlayerPieces-PlayerPositions, EnemyPositions, Row-Column, Size, Player).


can_be_saved([Player-_|PieceMoves]-[Row1-Column1|PositionsMoves], PlayerPieces-PlayerPositions, EnemyPositions, Row-Column, Size, Player):-
	append(EnemyPositions, [Row1-Column1], EnemyPositions1),
	!,
	\+is_move_winning(Size, EnemyPositions1, _-0),
	can_be_saved(PieceMoves-PositionsMoves, PlayerPieces-PlayerPositions, EnemyPositions, Row-Column, Size, Player).

% Checks if a move is winning move
% is_move_winning(+Size,+PlayerPositions,-Value)
is_move_winning(Size, PlayerPositions, Value-Value1):-
	get_pieces_at_edges(_-PlayerPositions, _-EdgesPositions, Size),
	!,
	\+is_empty(EdgesPositions),
	send_to_bfs(EdgesPositions, PlayerPositions, Size, [], _),
	Value is Value1 + 10000.

% Removes the previous position of a piece to check for other AI conditions
% remove_previous_position(+Positions,+PrevPosition,-PlayerPosition)
remove_previous_position([], _, []):-
	!.

remove_previous_position([PrevPosition|Positions], PrevPosition, PlayerPosition):-
	!,
	remove_previous_position(Positions, PrevPosition, PlayerPosition).

remove_previous_position([Position|Positions], PrevPosition, [Position|PlayerPosition]):-
	remove_previous_position(Positions, PrevPosition, PlayerPosition).


% Removes the previous piece of a position to check for other AI conditions
% remove_previous_piece(+Positions,+Pieces,+PrevPosition,-PlayerPositions)
remove_previous_piece([], [], _, []-[]):-
	!.

remove_previous_piece([PrevPosition|Positions], [_|Pieces], PrevPosition, PlayerPositions1-PlayerPieces1):-
	!,
	remove_previous_piece(Positions, Pieces, PrevPosition, PlayerPositions1-PlayerPieces1).

remove_previous_piece([Position|Positions], [Piece|Pieces], PrevPosition, [Position|PlayerPositions]-[Piece|PlayerPieces]):-
	remove_previous_piece(Positions, Pieces, PrevPosition, PlayerPositions-PlayerPieces).


% forms a list of pieces of height one equal to the size of the player's pieces positions
% form_pieces(+Positions, +Player, -Pieces)
form_pieces([], _, []).

form_pieces([_|Positions], Player, [Player-1|Pieces]):-
	form_pieces(Positions, Player, Pieces).
	
	
% gets the value of playing a certain positions and it increases if it is between 3 other enemy pieces
% get_value_between_three(+EnemyHeightPositionsAndPositions, +RowAndColumn, -Value)
get_value_between_three(EnemyHeightPositions, Row-Column, 100):-
	get_neighbour_pieces(_-EnemyHeightPositions, Row-Column, _-NeighbourPositions),
	length(NeighbourPositions, Size),
	Size >= 3,
	!.

get_value_between_three(_,_, 0).

get_value_near_high_piece(EnemyPositions-EnemyHeightPositions, Row-Column, Value):-
	get_above_one_height_positions(EnemyPositions, EnemyHeightPositions, AboveOneHeightPositions),
	get_neighbour_pieces(_-AboveOneHeightPositions, Row-Column, _-AboveOneHeightNeighbourPositions),
	\+is_empty(AboveOneHeightNeighbourPositions),
	!,
	Value is 8.

get_value_near_high_piece(_, _, 0).

% Calculates the value obtained by moving a piece near an enemy piece of height 1
% get_value_by_height(+EnemyHeightPositions, +RowAndColumn, -Value)
get_value_by_height(EnemyHeightPositions, Row-Column, Value):-
	
	get_neighbour_pieces(_-EnemyHeightPositions, Row-Column, _-EnemyNeighbourPositions),
	length(EnemyNeighbourPositions, Size),
	!,
	Value is Size*20.

% Calculates the value obtained by moving a piece near an enemy piece in order to obstruct it
% get_value_by_blocking(+RowAndColumn, +EnemyPositionsAndEnemyHeight1Positions, -Value)		
get_value_by_blocking(Row-Column, EnemyPositions-EnemyHeightPositions, Value):-
	get_neighbour_pieces(_-EnemyPositions, Row-Column, _-NeighbourPositions),
	length(NeighbourPositions, 1),
	get_first_element_of_list(NeighbourPositions, Row1-Column1),
	member(Row1-Column1, EnemyHeightPositions),
	get_neighbour_pieces(_-EnemyPositions, Row1-Column1, _-EnemyNeighbourPositions),
	!,
	get_path(EnemyPositions, EnemyNeighbourPositions, [Row1-Column1], Path),
	length(Path, Size),
	Value is 100*Size.



get_value_by_blocking(_, _, 0).
	

% Calculates the value obtained by moving a piece near a friendly piece
% get_value_by_path(+PlayerPositions, +RowAndColumn, -Value)
get_value_by_path(PlayerPositions, Row-Column, Value):-
	get_neighbour_pieces(_-PlayerPositions, Row-Column, _-NeighbourPositions),
	!,
	get_path(PlayerPositions, NeighbourPositions, [Row-Column], Path),
	length(Path, Size),
	length(NeighbourPositions, NeighbourSize),
	assign_value_by_size(NeighbourSize, Size, Value).
    	
% Gets all the pieces of height higher than one, normally used to get enemy pieces of height higher than one
% get_above_one_height_positions(+Positions, +EnemyHeight1Positions, -Result)
get_above_one_height_positions([], _, []).

get_above_one_height_positions([Row-Column|Positions], EnemyHeightPositions, [Row-Column|Result]):-
	\+member(Row-Column, EnemyHeightPositions),
	!,
	get_above_one_height_positions(Positions, EnemyHeightPositions, Result).

get_above_one_height_positions([_|Positions], EnemyHeightPositions, Result):-
	get_above_one_height_positions(Positions, EnemyHeightPositions, Result).

% gets the first element of a list passed by argument
% get_first_element_of_list(+List, -Element)
get_first_element_of_list([Element|[]], Element).


% returns a specific value depending on how many friendly pieces you already have connected
% assign_value_by_size(+IsEndOfLine, Size+, -Value)
assign_value_by_size(1, Size1, Value):-
	Value is 10*(Size1-1)+1.

assign_value_by_size(_, Size1, Value):-
	Value is 10*(Size1-1).

% returns a specific value depending if the move wins the game and what type of move was performed
% assign_value_win(+TypeOfMove, +EnemyPositions, +Size, -Value)
assign_value_win(_, EnemyPositions, Size, 0-_):-
	is_move_winning(Size, EnemyPositions, _-0),
	!.


assign_value_win(movenormal, _, _, Value-Value1):-
	Value is Value1 + 8000.

assign_value_win(movehigh, _, _, Value-Value1):-
	Value is Value1 + 7000.


