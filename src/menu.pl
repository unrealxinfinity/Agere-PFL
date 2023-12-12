% Responsible for transating the input to menu state 
% menu_input(+Input,-Event)
menu_input(0, exit).
menu_input(1, start).

% Responsible for transating the input to menu state or game mode
% menu_players_input(+Input,-Event)
menu_players_input(0, exit).
menu_players_input(1, back_menu). 
menu_players_input(2, cvc). 
menu_players_input(3, hvc). 
menu_players_input(4, hvh). 
% Responsible for transating the input to menu state or game difficulty
% menu_difficulty_input(+Input,-Event)
menu_difficulty_input(0, exit).
menu_difficulty_input(1, back_players).
menu_difficulty_input(2, hard).
menu_difficulty_input(3, easy).

% Responsible for transating the input to menu state or AI difficulty
% menu_difficulty_input_cvc(+Input,-Event)
menu_difficulty_input_cvc(0, exit).
menu_difficulty_input_cvc(1, back).
menu_difficulty_input_cvc(2, hard).
menu_difficulty_input_cvc(3, easy).

% Responsible for transating the input to menu state or starting player
% menu_choose_starting_player_input(+Input,-Event)
menu_choose_starting_player_input(0, exit).
menu_choose_starting_player_input(1, hvc).
menu_choose_starting_player_input(2, secondplayer).
menu_choose_starting_player_input(3, firstplayer).

% Responsible for transating the input to menu state or restarting the game
% menu_endgame_input(+Input,-Event)
menu_endgame_input(0, menu).
menu_endgame_input(1, restartgame).




% Initiates Agere game
% play/0
play :-
	draw_initial_menu,
	read_number_input(0, 1, Result),
	menu_input(Result, Event),
	menu_state(Event).
% Evaluates menu state and executes respective actions 
% menu_state(+Event)
menu_state(start):-
	draw_choose_player_type_menu,
	read_number_input(0, 4, Result),
	menu_players_input(Result, Event),
	menu_state(Event).

menu_state(exit):-
	draw_logo.

menu_state(back_menu):-
	play.

menu_state(back_players):-
	menu_state(start).

menu_state(back_cvc):-
	menu_state(cvc).

menu_state(hvh):-
	draw_choose_board_size_menu,
	read_numbers(1, 7, Size, _, _),
	initial_state(Size, GameState),
	initialise_game(GameState, human, human).

menu_state(hvc):-
	draw_choose_difficulty_menu('Please choose computer difficulty.'),
	read_number_input(0, 3, Result),
	menu_difficulty_input(Result, Difficulty),
	menu_state(Difficulty).

menu_state(cvc):-
	draw_choose_difficulty_menu('Please choose computer 1 difficulty.'),
	read_number_input(0, 3, Result),
	menu_difficulty_input(Result, Difficulty),
	menu_state(Difficulty, fill).

menu_state(easy):-
	draw_choose_starting_player,
	read_number_input(0, 3, Result),
	menu_choose_starting_player_input(Result, StartingPlayer),
	menu_state(StartingPlayer, easy).

menu_state(hard):-
	draw_choose_starting_player,
	read_number_input(0, 3, Result),
	menu_choose_starting_player_input(Result, StartingPlayer),
	menu_state(StartingPlayer, hard).

menu_state(exit, _):-
	!,
	menu_state(exit).

menu_state(hvc, _):-
	!,
	menu_state(hvc).

menu_state(firstplayer, Difficulty):-
	!,
	draw_choose_board_size_menu,
	read_numbers(1, 7, Size, _, _),
	initial_state(Size, GameState),
	initialise_game(GameState, human, Difficulty).
	
menu_state(secondplayer, Difficulty):-
	!,
	draw_choose_board_size_menu,
	read_numbers(1, 7, Size, _, _),
	initial_state(Size, GameState),
	initialise_game(GameState, Difficulty, human).	

menu_state(exit, _):-
	!,
	menu_state(exit).

menu_state(_, exit):-
	!,
	menu_state(exit).

menu_state(back_players, _):-
	!,
	menu_state(back_players).

menu_state(_, back_players):-
	!,
	menu_state(cvc).

menu_state(FirstDifficulty, fill):-
	draw_choose_difficulty_menu('Please choose computer 2 difficulty.'),
	read_number_input(0, 3, Result),
	menu_difficulty_input(Result, SecondDifficulty),
	menu_state(FirstDifficulty, SecondDifficulty).

menu_state(FirstDifficulty, SecondDifficulty):-
	draw_choose_board_size_menu,
	read_number_input(3, 7, Size),
	initial_state(Size, GameState),
	initialise_game(GameState, FirstDifficulty, SecondDifficulty).


menu_state(menu, _, _, _, _):-
	play.

menu_state(restartgame, GameState, Player1, Player2, MoveCount):-
	MoveCount mod 2 =:= 0,
	!,
	length(GameState, Size),
	initial_state(Size, GameState1),
	initialise_game(GameState1, Player1, Player2).	

menu_state(restartgame, GameState, Player1, Player2, _):-
	length(GameState, Size),
	initial_state(Size, GameState1),
	initialise_game(GameState1, Player2, Player1).	



% Initializes game
% initialise_game(+GameState,+Player1,+Player2)
initialise_game(GameState, Player1, Player2):-
	game(Player1, Player2, 0, GameState, o).
	

	
	



	
	
	