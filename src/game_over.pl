% Checks the left or right of a piece
% check_side(+Piece,+IsRight,+Size)
check_side([Row-Column|_], IsRight, Size):-
	Column is Size-Row+1+(2*(Row-1))*IsRight,	
	!.

check_side([_-_|Positions], IsRight, Size):-
	check_side(Positions, IsRight, Size).	

% Checks the bottom of a piece
% check_bottom(+Piece,+Size)
check_bottom([Size-_|_], Size).

check_bottom([_|Positions], Size):-
	check_bottom(Positions, Size).
	
% Bfs algorithm used to check winning condition
% bfs(+Visited,+Positions,+NextPositions,-Result)
bfs(Visited, _, [], Visited).

bfs(Visited, Positions, [Row-Column|NextPositions], Result):-
	\+member(Row-Column, Visited),
	append(Visited, [Row-Column], Visited1),
	get_neighbour_pieces(_-Positions, Row-Column, _-NeighbourPositions),
	append(NextPositions, NeighbourPositions, NextPositions1),
	bfs(Visited1, Positions, NextPositions1, Result).

bfs(Visited, Positions, [_-_|NextPositions], Result):-
	bfs(Visited, Positions, NextPositions, Result).


% Checks if the player has won
% has_won(+Visited,+Size,+VisitedBfs,+Positions,+NextIteration,-Path)
has_won(VisitedBfs, Size, _, _, _, VisitedBfs):-
	check_bottom(VisitedBfs, Size),
	check_side(VisitedBfs, 0, Size),
	check_side(VisitedBfs, 1, Size).

has_won(VisitedBfs, Size, Visited, Positions, NextIteration, Path):-
	append(Visited, VisitedBfs, Visited1),
	send_to_bfs(NextIteration, Positions, Size, Visited1, Path).

	

% Checks for each valid position for winning condition using bfs to get the path
% send_to_bfs(+NextIteration,+Positions,+Size,+Visited,-Path)
send_to_bfs([Row-Column|NextIteration], Positions, Size, Visited, Path):-
	\+member(Row-Column, Visited),
	get_neighbour_pieces(_-Positions, Row-Column, _-NeighbourPositions),
	bfs([Row-Column], Positions, NeighbourPositions, Visited1),
	!,
	has_won(Visited1, Size, Visited, Positions, NextIteration, Path).

send_to_bfs([_|NextIteration], Positions, Size, Visited, Path):-
	send_to_bfs(NextIteration, Positions, Size, Visited, Path).




% Checks if theres any winner and returns the winner
% check_end_condition(+GameState,-Winner)
check_end_condition(GameState, b):-
	length(GameState, Size),
	get_pieces_by_color(GameState, b, _-BluePositions),
	get_pieces_at_edges(_-BluePositions, _-EdgesPositions, Size),
	\+is_empty(EdgesPositions),
	send_to_bfs(EdgesPositions, BluePositions, Size, [], _).

check_end_condition(GameState, y):-
	length(GameState, Size),
	get_pieces_by_color(GameState, y, _-YellowPositions),
	get_pieces_at_edges(_-YellowPositions, _-EdgesPositions, Size),
	\+is_empty(EdgesPositions),
	send_to_bfs(EdgesPositions, YellowPositions, Size, [], _).

check_end_condition(_, o).

% Checks if the game is over
% game_over(+GameState,-Winner)
game_over(GameState, Winner):-
	check_end_condition(GameState, Winner).



% Gets the path of a player with the same color
% get_path(+PlayerPositions,-Path)
get_path(_, [], Path, Path).

get_path(PlayerPositions, [Row-Column|Queue], Acc, Path):-
	\+member(Row-Column, Acc),
	!,
	get_neighbour_pieces(_-PlayerPositions, Row-Column, _-NeighbourPositions),
	append(Acc, [Row-Column], Acc1),
	append(Queue, NeighbourPositions, Queue1),
	get_path(PlayerPositions, Queue1, Acc1, Path).

get_path(PlayerPositions, [_|Queue], Acc, Path):-
	get_path(PlayerPositions, Queue, Acc, Path).

	
	







