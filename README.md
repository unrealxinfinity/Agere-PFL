# AGERE_4

## Trabalho realizado por
- Haochang Fu (upxxxxxxxxx)
- João Miguel Vieira Cardoso (up202108732)
## Pré-requesitos, instalação e execução
- Ter Sicstus instalado;
- Descomprimir todos os ficheiros da pasta zip para uma pasta nova desde que consiga correr Sicstus nela;
- Executar Sicstus, consultar o ficheiro "proj.pl" e começar a jogar.

## Descrição do jogo

O nome do jogo é Agere e trata-se de um jogo de tabuleiro que pode ser jogado por 2 jogadores, que por sua vez podem ser pessoas ou o computador.

O objetivo do jogo é ligar os 3 lados do tabuleiro com as peças da sua cor.

No início do jogo, o primeiro jogador usa as peças de cor amarela (representadas por Y) e o segundo jogador utiliza as peças de cor azul (representadas por B). Na eventualidade de haver uma peça por cima de outra, nós também representamos o número de peças que estão numa determinada posição do tabuleiro com um número. Por exemplo se houver uma peça amarela numa posição com uma azul por baixo dela, então representamo-la desta forma (Y2). O número máximo de altura é 9.

O tabuleiro apresenta forma triangular, tendo cada posição ou "casa" um aspeto hexagonal. O tamanho do tabuleiro pode variar consoante o que o jogador escolhe no menu: small, medium, large.

No menu também será possível escolher o tipo de adversário que pode ser human vs human, human vs computer ou computer vs computer.

As regras de jogo resume-se a duas decisões que os jogadores podem tomar em cada turno:

- Adicionar uma peça da sua cor ao tabuleiro: Os jogadores selecionam a posição onde pretendem colocar a sua peça, sendo que a posição onde a colocam não pode ter uma peça já nela colocada.
- Mover uma peça da sua cor para cima de uma peça adversária: Pegar numa peça da sua cor e movê-la para cima de uma peça adversária vizinha dela. No entanto, isto só é possível se a peça adversária tiver a mesma altura que a peça que pretendes mover. Na maneira como o nosso jogo está feito, só se o número ao lado das peças forem iguais é que será possível fazer isto.

O jogo acaba quando houver uma ligação contínua de peças da mesma cor a ligar os 3 lados do tabuleiro. Mal que este estado se verifique, o jogo imediatamente termina e o jogador dono das peças que ligaram os lados do tabuleiro pronuncia-se como vencedor do jogo.

[Link para regras do jogo em pdf](https://boardgamegeek.com/filepage/263282/agere-rules)
## Lógica do jogo

O código do programa foi separado em diferentes ficheiros de acordo com as suas funções no programa:
- AI.pl: Responsável pela inteligencia arteficial que é responsável por trás do computador como jogador;
- board.pl: Responsável pelos predicados que fazem a pesquisa e alteram o estado do tabuleiro (GameState);
- display.pl: Responsável pelo output de vários elementos como o tabuleiro, o menu e o jogo;
- game.pl: Responsável pela lógica durante a execução de uma partida em Agere;
- menu.pl: Responsável pelas interações feitas ao menu e tudo relacionado;
- proj.pl: Ficheiro a executar para começar o programa e inclui as livrarias que o programa usa para correr.

### 1. Representação do estado do jogo
  Para representar o  GameState, o programa usa uma lista de listas (matrix) em que cada fila corresponde a uma fila no triangulo e cada elemento dentro de uma sublista corresponde a uma peça que está na forma Color-Height, neste caso o GameState corresponde ao estado do tabuleiro. O comprimento que o jogador introduzir no inicio, no menu, determina o tamanho do tabuleiro. O triangulo é uma porção da matrix de comprimento lado x lado. Este é inicializado com predicado **initial_state(+Size,-GameState)** em que leva tamanho do lado do triangulo como input e retorna o GameState com posições vazias no inicio da forma o-0.
  
  Para representar o jogador temos 2 cores que os corresponde e uma cor que representa espaço vazio: y(yellow) , b(blue) e o(empty).
  
  Para aglomerar o estado do tabuleiro e o estado do jogador, temos predicado **game(+CurrPlayerType, +NextPlayerType, +MoveCount, +GameState, -Winner)** que representa o estado do jogo e vai alternando os turnos do jogador fazendo chamadas recursivas.
  
  Durante a execução de uma partida, a lógica do jogo junta as peças do tabuleiro com as suas respetivas posições no tabuleiro em forma de par [lista de todas as peças]-[lista das suas respetivas posições no tabuleiro], enquanto calcula as posições válidas para o jogador com o predicado **valid_moves(+GameState, +Player, -ListOfMoves)**. A tradução das posições na matrix para posições de um tabuleiro triangular foi um dos desafios, o tabuleiro está representado com matrix de filas desde 1 elemento até ao número de lado que jogador introduziu. Desta forma, para calcular a coluna da posição de uma peça correspondente ao tabuleiro, foi usado a fórmuma (Número de filas do tabuleiro) - (Número de elementos de uma fila) + 1 - 2*(numero da coluna da peça no matrix).
