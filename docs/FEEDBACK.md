# Feedback de playtest do Orlando

Registro cru do que o Orlando sentiu jogando, em ordem. Cada item tem um id, o que ele disse, o que o código faz hoje e para onde vai. Nada aqui muda regra sozinho: mudança de fórmula ou de regra do GDD exige ADR, GDD atualizado, `RULES_VERSION` e nova rodada do simulador (CLAUDE.md, regra 3). Quando virar tarefa, trocar "Aberto" por "Em TASK-NNN".

## 2026-11-16, depois de jogar as TASK-009 a 013

### F-001: o chefe lança ataques de moeda demais em sequência

- **Status:** atendido na TASK-016 (ADR-0020), falta o Orlando confirmar jogando: intervalo mínimo de 2 golpes entre golpes de moeda, sem exceção para chefes; a exceção da fase final foi removida e o Coveiro ficou com 1 golpe de moeda por fase de 5 golpes, mais os dois novos golpes de debuff. Fica mais evidente desde a TASK-015, porque agora o jogador escolhe o lado em cada lance.
- **Hoje:** o GDD §7 e o ADR-0008 proíbem dois golpes de moeda seguidos, exceto na fase final de chefe; o ADR-0012 calibrou o Coveiro com 2 golpes de moeda em 4 na fase final, e mesmo antes disso o ciclo dele tem vários. Mortes por moeda no simulador: 31% e 35%, acima da meta de 25% (pendência 5 do HANDOFF).
- **Direção:** tirar a exceção dos chefes ou limitar a um golpe de moeda a cada 3 turnos; recalibrar o Coveiro com o simulador. Exige ADR, GDD §7 e `RULES_VERSION`.

### F-002: o chefe precisa de ataques com debuff por probabilidade; senão a moeda decide tudo

- **Status:** atendido na TASK-016 (ADR-0020), falta o Orlando confirmar jogando: golpes `debuff` (Toque Podre com Veneno 60%, Maldição do Coveiro com Fraqueza 70%), chance própria no fluxo de combate, aviso DEBILITA com a chance e Defender cortando pela metade. Falta: Sangramento, doenças, itens e skills que curam, e debuffs em inimigos comuns.
- **Hoje:** todo golpe especial do inimigo é "moeda e dano maior" (Pesado, Cruel, Mortal). O Golpe Cruel deveria dar debuff ou risco de doença na Coroa (GDD §7), mas o ADR-0008 (decisão 8) deixou isso para depois; doenças e debuffs de inimigo ainda não existem. Resultado: a única variável de risco é a moeda.
- **Direção:** golpes com efeito (veneno, sangramento, Lentidão, Guarda aberta, doença do GDD §11) que acertam por chance própria (fluxo de combate, não o da moeda), visíveis com ícone e chance no aviso, e que o jogador possa mitigar (Defender, itens). A moeda continua para os golpes de risco, mas não é o único. Precisa de sistema de efeitos no inimigo e no jogador; provável ADR de efeitos e doenças.

### F-003: matar inimigos não dá senso de progressão

- **Status:** em andamento. A TASK-017 (ADR-0021) entregou o retorno visual: a recompensa lista quem caiu e cada atributo antes e depois, o mapa mostra FOR, DEF, VEL e inimigos derrotados, e a luta ganhou números de dano e animação de abate. **Achado:** com o Poder subindo 0,15 por nível de inimigo, uma luta comum no começo muda só 1 ou 2 de HP e nada nos demais atributos. O retorno agora aparece, mas é pequeno. A causa é a economia (GDD §9), não a tela. Decisão do Orlando pendente: drops de equipamento dos inimigos, marcos por camada ou mudar a curva do Poder (qualquer um exige ADR e nova calibração).
- **Hoje:** a vitória só rende Poder (invisível durante o mapa, sem barra), ouro e a loja; o único retorno é um texto na tela de recompensa. Não há dropes, nível visível, nem sensação de a Bibiana ficar mais forte entre uma luta e outra.
- **Direções a avaliar (propostas, não decididas):** mostrar o Poder como progresso da Descida (barra e ganho de atributos explícito, "FOR 14 → 16"); drops de itens e equipamentos dos inimigos, com a raridade do GDD §10; marcos por camada; efeito e texto de abate; a Bibiana ganhando algo permanente por inimigo-tipo (códice, §11). Pede conversa com o Orlando antes de virar tarefa, porque mexe no laço central do jogo.

## Como isso entra no roteiro

Propostas, a decidir com o Orlando depois da TASK-014 (portão da Fase 1):

1. **TASK-016, ajuste do laço de combate:** F-001 e F-002 (ritmo de moeda do chefe, efeitos e debuffs por probabilidade), com ADR e nova rodada do simulador.
2. **TASK-017, progressão visível:** F-003, depois de definir a direção.

## 2026-11-16, depois da TASK-017

### F-004: faltam as mecânicas básicas de um roguelike RPG: ganho de status, drops e magias na loja

- **Status:** atendido nas TASK-018, 019 e 020 (ADR-0022, 0023 e 0024); falta o Orlando confirmar jogando. Escolhida pelo Orlando como direção do F-003 (drops dos inimigos) e ampliada.
- **Pedido (três pontos):** (1) ganho de status que se sinta, (2) drops de inimigos, (3) novas magias (skills) para comprar na loja.
- **Plano, uma tarefa por ponto, nesta ordem:**
  1. **TASK-018, drops e equipamento:** inimigos soltam equipamento e consumíveis; a recompensa pergunta "Equipar ou Vender"; novos itens de arma, armadura e relíquia, com raridade.
  2. **TASK-019, ganho de status:** a Bibiana sobe de nível de forma discreta, com ganho de atributos que se vê.
  3. **TASK-020, skills na loja:** novas skills do Guerreiro à venda, com mais espaços de skill no combate.
