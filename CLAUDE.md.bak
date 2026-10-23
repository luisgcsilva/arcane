# Arcane

Dungeon RPG por turnos em Lua + LÖVE, para correr numa R36S (ArkOS, 640x480).
O Luís está a aprender Lua: explicar cada conceito novo, passos pequenos,
e propor desafios em vez de fazer tudo sozinho.

## Regras do projecto
- Ficheiros base: main.lua, conf.lua (title "Arcane", identity "arcane", 640x480),
  input.lua, jogo.lua (gestor de estados: registar, mudar(nome, ...), abrir/fechar).
- Dados (tabelas, desenho orientado a dados): inimigos, intencoes, efeitos,
  habilidades, classes, reliquias, loot, pocoes, mercador, salas, eventos,
  biomas, bencoes. Para adicionar conteudo, editar a tabela, nao a logica.
- Estados em estados/: menu, classes, explorar, portas, combate, habilidade,
  reliquia, loja, fogueira, tesouro, evento, santuario, inventario, historico,
  derrota, final, ajuda, simulacao. Cada novo estado registar em main.lua e acrescentar
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
- Santuario (sala nova, estados/santuario.lua + bencoes.lua): oferece 3
  bencoes a sorte, cada uma com preco (vida ou moedas). Dura 5 salas, so uma
  ativa (jogador.bencao). Os bonus passam por jogador.bonus (chaves ataque_pct,
  defesa_pct, moedas, fuga). A oferta fica gravada (jogador.ofertaBencaos).
- Loja: o Treino (mercador.TREINO) compra vida maxima, ataque e defesa com
  preco sempre a subir; sorvedouro de ouro. Avisos coloridos (verde/vermelho/
  laranja para mochila cheia); mensagens do combate partem linha com printf.
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

## Equilibrio (ultima simulacao, 1000 jogos por classe)
Chegam a sala 100: Mago ~29%, Guerreiro ~22%, Ninja ~19%. Curva de mortes
regular por bioma. Sobram ~2000-3000 moedas no fim. Considerado fechado ate
haver mais jogo humano. O bot nao simula eventos nem santuarios.

## Proximos passos
1. Mais eventos (so dados em eventos.lua), 6 a 8 novos.
2. Cofre trancado (chaves largadas por elites).
3. Santuario parte 2: reliquia amaldicoada.
4. Meta-progressao (desbloquear classes/reliquias), sprites e som.
Antes de empacotar: jogador.moedas = 0 no reiniciar, SALA_FINAL = 100,
DEBUG = false, DEV = false no menu. Falta testar na R36S as linhas partidas
(loja, combate, santuario) e os tamanhos de texto.
