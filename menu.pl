menu_input(0, exit).
menu_input(1, start).
menu_players_input(0, exit).
menu_players_input(1, back_menu). 
menu_players_input(2, cvc). 
menu_players_input(3, hvc). 
menu_players_input(4, hvh). 

menu_difficulty_input(0, exit).
menu_difficulty_input(1, back_players).
menu_difficulty_input(2, hard).
menu_difficulty_input(3, easy).

menu_difficulty_input_cvc(0, exit).
menu_difficulty_input_cvc(1, back).
menu_difficulty_input_cvc(2, hard).
menu_difficulty_input_cvc(3, easy).


menu_final_input(2, easy).
menu_final_input(3, hard).

menu_final_input_cvc(0, exit).
menu_final_input_cvc(1, back).
menu_final_input_cvc(2, easy).
menu_final_input_cvc(3, hard).

	
menu :-
	draw_initial_menu,
	read_number_input(0, 1, Result),
	menu_input(Result, Event),
	menu_state(Event).

menu_state(start):-
	draw_choose_player_type_menu,
	read_number_input(0, 4, Result),
	menu_players_input(Result, Event),
	menu_state(Event).

menu_state(exit):-
	draw_logo.

menu_state(back_menu):-
	menu.

menu_state(back_players):-
	menu_state(start).

menu_state(back_cvc):-
	menu_state(cvc).

menu_state(hvh):-
	draw_choose_board_size_menu,
	read_numbers(1, 15, Size),
	initial_state(Size, GameState),
	start(1, 2, GameState).

menu_state(hvc):-
	draw_choose_difficulty_menu('Please choose computer difficulty.'),
	read_number_input(0, 4, Result),
	menu_difficulty_input(Result, Difficulty),
	menu_state(Difficulty).

menu_state(cvc):-
	draw_choose_difficulty_menu('Please choose computer 1 difficulty.'),
	read_number_input(0, 4, Result),
	menu_difficulty_input(Result, Difficulty),
	menu_state(Difficulty, fill).

menu_state(easy):-
	draw_choose_board_size_menu,
	read_number_input(3, 9, Size).

menu_state(hard):-
	draw_choose_board_size_menu,
	read_number_input(3, 9, Size).

menu_state(exit, _):-
	!,
	menu_state(exit).

menu_state(_, exit):-
	!,
	menu_state(exit).

menu_state(back_players, _):-
	!,
	menu_state(back_players).

menu_state(FirstDifficulty, back_players):-
	!,
	menu_state(cvc).

menu_state(FirstDifficulty, fill):-
	draw_choose_difficulty_menu('Please choose computer 2 difficulty.'),
	read_number_input(0, 4, Result),
	menu_difficulty_input(Result, SecondDifficulty),
	menu_state(FirstDifficulty, SecondDifficulty).

menu_state(FirstDifficulty, SecondDifficulty):-
	draw_choose_board_size_menu,
	read_number_input(3, 9, Size).


	
	
	
	



	
	
	