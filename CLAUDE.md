# Arcane

Dungeon RPG por turnos em Lua + LÖVE, para correr numa R36S (ArkOS, 640x480).
O Luís está a aprender Lua: explicar cada conceito novo, passos pequenos,
e propor desafios em vez de fazer tudo sozinho.

## Regras do projecto
- Ficheiros base: main.lua, conf.lua (title "Arcane", identity "arcane", 640x480),
  input.lua, jogo.lua (gestor de estados: registar, mudar(nome, ...), abrir/fechar).
- Dados (tabelas, desenho orientado a dados): inimigos, intencoes, efeitos,
  habilidades, classes, reliquias, loot, pocoes, mercador, salas, eventos,
  biomas. Para adicionar conteudo, editar a tabela, nao a logica.
- Estados em estados/: menu, classes, explorar, portas, combate, habilidade,
  reliquia, loja, fogueira, tesouro, evento, inventario, historico, derrota,
  final, ajuda, simulacao. Cada novo estado registar em main.lua e acrescentar
  entrada em estados/ajuda.lua (dados e TITULOS).
- Na R36S só aparecem ficheiros .love, na pasta love2d de EASYROMS.
  Empacotar com tar (caminhos com /), script empacotar.ps1.
- Input: todo traduzido para acções em input.lua (cima, baixo, esquerda,
  direita, confirmar, cancelar, menu, extra, ombro_esq, ombro_dir,
  gatilho_esq, gatilho_dir, inventario, pausa). A = confirmar, B = cancelar.
- Botões da R36S chegam via love.joystickpressed (números):
  d-pad 15 cima, 16 baixo, 17 esquerda, 18 direita; A1 B2 X3 Y4;
  L1 5, R1 6, L2 7, R2 8; SELECT 9, START 10.
- O analógico esquerdo gera teclas (up/down/left/right); são ignoradas
  quando há joystick ligado. Controlo só por botões.
- Cada estado tem entrar(), acao(a), desenhar(). Inimigos copiados
  com pairs antes de usar (não alterar o modelo).

## Estado actual
Jogo completo e jogavel, testado no PC e na R36S.
- 3 classes (Guerreiro, Ninja, Mago), habilidades, 18 reliquias, loot com
  raridades (comum a mitica), loja com Ferreiro, fogueiras, tesouros, eventos.
- 100 salas em 10 biomas (biomas.lua, 10 salas por bioma). Chefe a cada 10
  salas, loja na sala antes do chefe. Chefes declaram os seus biomas.
- Sala 100 = fim do jogo: estados/final.lua (continuar em modo infinito ou
  terminar). dificuldade.SALA_FINAL = 100. Recordes contam vitorias.
- Ferreiro: as melhorias ficam na ranhura (jogador.forja.arma/armadura),
  nao no item; o bonus mostra-se "base +melhoria". Tetos em mercador.MAX_FORJA.
- Gravacao automatica (savegame.lua, partida.txt), historico de partidas,
  recordes.
- Balanceamento por simulacao: simulacao.lua corre o bot N vezes e escreve
  simulacao.txt/.csv. Escala de inimigos em dificuldade.fator; chefes nao
  escalam (afinados a mao). Rever depois de qualquer mudanca de equilibrio.
- Nomes de inimigos tem de ser unicos (o savegame restaura por nome).
- DEBUG em main.lua deve ficar false; DEV em estados/menu.lua esconde a
  Simulacao quando false.

## Proximos passos
Pendentes: novos tipos de sala (cofre, armadilha com escolha, desafio,
santuario), meta-progressao/conquistas, sprites e som ou mapa em grelha,
reequilibrar classes (Ninja fraco, Mago forte) depois de jogar a serio,
nova simulacao com os tetos do Ferreiro novos.
