initial_state(Size, GameState) :-
    initial_state(Size, 1, GameState).

initial_state(Size, Size, [Row]):-
	make_row(Size, Row, b).

initial_state(Size, RowSize, [Row | List]) :-
    make_row(RowSize, Row, b), 
    RowSize1 is RowSize + 1,
    initial_state(Size, RowSize1, List).

make_row(0, [], _).

make_row(Size, [Piece | List], Piece) :- 
    Size > 0,
    Size1 is Size - 1,
    make_row(Size1, List, Piece).



start(Player1, Player2, GameState) :- 
	display_game(GameState).


	