% Initializes the board
% initial_state(+Size,-GameState)
initial_state(Size, GameState) :-
    	initial_state(Size, 1, GameState).

initial_state(Size, Size, [Row]):-
	make_row(Size, Row, o-0).

initial_state(Size, RowSize, [Row | List]) :-
    	make_row(RowSize, Row, o-0), 
    	RowSize1 is RowSize + 1,
    	initial_state(Size, RowSize1, List).

make_row(0, [], _).

% Makes a row for the game board
% make_row(+Size,-Row,+Piece)
make_row(Size, [Piece | List], Piece) :- 
    	Size > 0,
    	Size1 is Size - 1,
    	make_row(Size1, List, Piece).


% Fails if the list passed by argument is empty
% is_empty([])
is_empty([]).



%Check if the variables are equal
%compare(?Var, ?Var)
compare(Var, Var).


% Gets a piece and its position from the board in a certain position
% get_piece(+Row,+PieceColor,-PieceAndPosition,+Size,+RowSize,+Offset)
get_piece([], _, []-[], _, _, _).

get_piece([Piece-Height|Row], Piece, [Piece-Height|PieceRow]-[RowSize-Position|PositionRow], Size, RowSize, Offset):-
	!,
	Position is Size-RowSize+1+Offset,
	Offset1 is Offset+2,
	get_piece(Row, Piece, PieceRow-PositionRow, Size, RowSize, Offset1).

get_piece([_-_|Row], Color, PieceRow-PositionRow, Size, RowSize, Offset):-
	Offset1 is Offset+2,
	get_piece(Row, Color, PieceRow-PositionRow, Size, RowSize, Offset1).
% Gets the pieces of a row of the same color
% get_pieces(+Row,+Color,-PiecesAndPositions,+Acc,+Size)
get_pieces([], _, PieceList-PositionList, PieceList-PositionList, _).

get_pieces([Row|List], Color, PieceList-PositionList, PieceAcc-PositionAcc, Size):-
	length(Row, RowSize),
	get_piece(Row, Color, PieceRow-PositionRow, Size, RowSize, 0),
	append(PieceAcc, PieceRow, PieceAcc1),
	append(PositionAcc, PositionRow, PositionAcc1),
	get_pieces(List, Color, PieceList-PositionList, PieceAcc1-PositionAcc1, Size).

% Gets all the pieces in a board of the same color
% get_pieces_by_color(+GameState,+Color,-PiecesAndPositions)
get_pieces_by_color(GameState, Color, PieceList-PositionList):-
	length(GameState, Size),
	get_pieces(GameState, Color, PieceList-PositionList, []-[], Size).



% Gets height of a Piece
% check_height(+Piece,-Height)
check_height(_-Height,Height).

% Gets the moves of the same height in a given set of moves
% get_moves_same_height(+Pieces,+Height,Acc,FilteredPiecesAndPositions)
get_moves_same_height([]-[],_,FilteredPieces-FilteredPositions, FilteredPieces-FilteredPositions).

get_moves_same_height([Piece|RestPieces]-[Position|RestPositions],Height,ListPieceAcc-ListPosAcc,FilteredPieces-FilteredPositions):-
    check_height(Piece,Height),
    !,
    append(ListPieceAcc,[Piece],NewFilteredPieces),
    append(ListPosAcc,[Position],NewFilteredPositions),
    get_moves_same_height(RestPieces-RestPositions,Height,NewFilteredPieces-NewFilteredPositions,FilteredPieces-FilteredPositions).
    
get_moves_same_height([_|RestPieces]-[_|RestPositions],Height,ListPieceAcc-ListPosAcc,FilteredPieces-FilteredPositions):-
    get_moves_same_height(RestPieces-RestPositions,Height,ListPieceAcc-ListPosAcc,FilteredPieces-FilteredPositions).

% Predicate to initialize get_moves_same_height
% get_pieces_by_height(
get_pieces_by_height(PieceList-PositionList, Height, PieceListRes-PositionListRes):-
	get_moves_same_height(PieceList-PositionList, Height, []-[], PieceListRes-PositionListRes).









% Checks if a position is neighbour of another position
% is_neighbour(+Position1,+Position2)
is_neighbour(Row-Column, Row1-Column1):-
	Row is Row1-1,
	NumberMin is Column1 - 1,
	NumberMax is Column1+1,
	between(NumberMin, NumberMax, Column),
	!.

is_neighbour(Row-Column, Row1-Column1):-
	Row is Row1+1,
	NumberMin is Column1 - 1,
	NumberMax is Column1 +1,
	between(NumberMin, NumberMax, Column),
	!.


is_neighbour(Row-Column, Row-Column1):-
	Column is Column1 - 2,
	!.


is_neighbour(Row-Column, Row-Column1):-
	Column is Column1+2,
	!.
% Gets all the neighbour pieces
% get_neighbour_pieces(+ValidMoves,+Position,-Neighbours)
get_neighbour_pieces([]-[], _-_,[]-[]).


get_neighbour_pieces([Piece-Height|Pieces]-[Row-Column|Positions], Letter-Number, [Piece-Height|PiecesRes]-[Row-Column|PositionsRes]):-
	is_neighbour(Row-Column, Letter-Number),
	!,
	get_neighbour_pieces(Pieces-Positions, Letter-Number, PiecesRes-PositionsRes).




get_neighbour_pieces([_-_|Pieces]-[_-_|Positions], Letter-Number, PiecesRes-PositionsRes):-
	get_neighbour_pieces(Pieces-Positions, Letter-Number, PiecesRes-PositionsRes).

% Gets all the pieces with enemy neighbours
% get_pieces_with_enemy_neighbours(+Pieces,+EnemyPieces,-PiecesWithEnemyNeighbours)

get_pieces_with_enemy_neighbours([]-[], _-_, []-[]).

get_pieces_with_enemy_neighbours([Piece-Height|Pieces]-[Row-Column|Positions], EnemyPieces-EnemyPositions, [Piece-Height|PiecesRes]-[Row-Column|PositionsRes]):-
	get_neighbour_pieces(EnemyPieces-EnemyPositions, Row-Column, EnemyNeighbourPieces-EnemyNeighbourPositions),
	get_pieces_by_height(EnemyNeighbourPieces-EnemyNeighbourPositions, Height, _-EnemyNeighbourHeightPositions),
	\+is_empty(EnemyNeighbourHeightPositions),
	!,
	get_pieces_with_enemy_neighbours(Pieces-Positions, EnemyPieces-EnemyPositions, PiecesRes-PositionsRes).
	

get_pieces_with_enemy_neighbours([_-_|Pieces]-[_-_|Positions], EnemyPieces-EnemyPositions, PiecesRes-PositionsRes):-
	get_pieces_with_enemy_neighbours(Pieces-Positions, EnemyPieces-EnemyPositions, PiecesRes-PositionsRes).







% Gets the pieces at the edges of the board
% get_pieces_at_edges(+Pieces,-PiecesAtEdges,+Size)
get_pieces_at_edges([]-[], []-[], _).

get_pieces_at_edges([Color-Height|Pieces]-[Row-Column|Positions], [Color-Height|PiecesRes]-[Row-Column|PositionsRes], Size):-
	Column is Size-Row+1+2*(Row-1),
	!,
	get_pieces_at_edges(Pieces-Positions, PiecesRes-PositionsRes, Size).

get_pieces_at_edges([Color-Height|Pieces]-[Row-Column|Positions], [Color-Height|PiecesRes]-[Row-Column|PositionsRes], Size):-
	Column is Size-Row+1,
	!,
	get_pieces_at_edges(Pieces-Positions, PiecesRes-PositionsRes, Size).

get_pieces_at_edges([_-_|Pieces]-[_-_|Positions], PiecesRes-PositionsRes, Size):-
	get_pieces_at_edges(Pieces-Positions, PiecesRes-PositionsRes, Size).




% Travesses the row and finds a piece
% find_row(+Row,+Position,+Offset,+Size,+Player,-NewRow,-Color-Height)
find_row([Row|List], LetterInput-NumberInput, Offset, Size, Player, [Row|NewList], Color-Height):-
	length(Row, RowSize),
	RowSize =\= LetterInput,
	!,
	find_row(List, LetterInput-NumberInput, Offset, Size, Player, NewList, Color-Height).

find_row([Row|List], _-NumberInput, Offset, Size, Player, [NewRow|List], Color-Height):-
	length(Row, RowSize),
	find_piece(Row, NumberInput, Offset, Size, RowSize, Player, NewRow, Color-Height).
	
% Finds a piece in a row
% find_piece(+Row,+Position,+Offset,+Size,+RowSize,+Player,-NewRow,-Color-Height)
find_piece([Piece-Height|List], NumberInput, Offset, Size, RowSize, Player, [Piece-Height|NewList], Color-Height1):-
	Size-RowSize+1+Offset =\= NumberInput,
	!,
	Offset1 is Offset + 2,
	find_piece(List, NumberInput, Offset1, Size, RowSize, Player, NewList, Color-Height1).

find_piece([o-Height|List], _, _, _, _, Player, [Player-1|List], o-Height):-
	!.

find_piece([Piece-Height|List], _, _, _, _, _, [Piece-Height|List], Piece-Height).


% Travesses columns for moving a piece
% loop_column_move(+Row,+Position,+Offset,+Size,+RowSize,-NewRow)
loop_column_move([], _, _, _, _, []).

loop_column_move(Row, (0-0)-(0-0), _, _, _, Row).

loop_column_move([Piece-Height|Row], (PrevX-RowSize)-(X-Y), Size, Offset, RowSize, [EnemyPiece-Height1|NewRow]):-
	PrevX is Size-RowSize+1+Offset,
	Height1 is Height-1,
	Height1 > 0,
	!,
	enemy_of(Piece, EnemyPiece),
	Offset1 is Offset+2,
	loop_column_move(Row, (0-0)-(X-Y), Size, Offset1, RowSize, NewRow).

loop_column_move([_-Height|Row], (PrevX-RowSize)-(X-Y), Size, Offset, RowSize, [o-Height1|NewRow]):-
	PrevX is Size-RowSize+1+Offset,
	!,
	Height1 is Height-1,
	Offset1 is Offset+2,
	loop_column_move(Row, (0-0)-(X-Y), Size, Offset1, RowSize, NewRow).

loop_column_move([Piece-Height|Row], (PrevX-PrevY)-(X-RowSize), Size, Offset, RowSize, [CurrPlayer-Height1|NewRow]):-
	X is Size-RowSize+1+Offset,
	!,
	enemy_of(Piece, CurrPlayer),
	Height1 is Height+1,
	Offset1 is Offset+2,
	loop_column_move(Row, (PrevX-PrevY)-(0-0), Size, Offset1, RowSize, NewRow).



loop_column_move([Piece|Row], (PrevX-PrevY)-(X-Y), Size, Offset, RowSize, [Piece|NewRow]):-
	Offset1 is Offset+2,
	loop_column_move(Row, (PrevX-PrevY)-(X-Y), Size, Offset1, RowSize, NewRow).


% Travesses the rows for moving a piece
% loop_row_move(+GameState,+Position,+Size,-NewGameState)
loop_row_move([], _, []).

loop_row_move(Rows, (0-0)-(0-0), _, Rows).

loop_row_move([Row|Rows], (PrevX-RowSize)-(X-RowSize), Size, [NewRow|Rows]):-
	length(Row, RowSize),
	!,
	loop_column_move(Row, (PrevX-RowSize)-(X-RowSize), Size, 0, RowSize, NewRow). 

loop_row_move([Row|Rows], (PrevX-RowSize)-Next, Size, [NewRow|NewRows]):-
	length(Row, RowSize),
	loop_column_move(Row, (PrevX-RowSize)-(0-0), Size, 0, RowSize, NewRow),
	loop_row_move(Rows, (0-0)-Next, Size, NewRows).

loop_row_move([Row|Rows], Previous-(X-RowSize), Size, [NewRow|NewRows]):-
	length(Row, RowSize),
	loop_column_move(Row, (0-0)-(X-RowSize), Size, 0, RowSize, NewRow),
	loop_row_move(Rows, Previous-(0-0), Size, NewRows).

loop_row_move([Row|Rows], Coordinates, Size, [Row|NewRows]):-
	loop_row_move(Rows, Coordinates, Size, NewRows).
