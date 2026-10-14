# Arcane

Dungeon RPG por turnos em Lua + LÖVE, para correr numa R36S (ArkOS, 640x480).
O Luís está a aprender Lua: explicar cada conceito novo, passos pequenos,
e propor desafios em vez de fazer tudo sozinho.

## Regras do projecto
- Ficheiros: main.lua, conf.lua (title "Arcane", identity "arcane", 640x480),
  input.lua, jogo.lua (gestor de estados), inimigos.lua (dados),
  estados/menu.lua, estados/explorar.lua.
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
Menu inicial a funcionar (Novo jogo / Sair) e estado "explorar" provisório
a mostrar um inimigo. Testado no PC e na R36S.

## Próximos passos
Inimigo aleatório (math.random + randomseed), combate por turnos,
salas geradas com loot, inventário, guardar progresso (love.filesystem).