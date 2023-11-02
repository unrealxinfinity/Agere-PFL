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
