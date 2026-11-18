# ADR-0034: Santuário e meta-progresso (Biblioteca, Arsenal e Códice)

- **Status:** Aceito
- **Data:** 2026-11-18
- **Tarefa:** TASK-030

## Contexto

Até a `TASK-028`, os Ecos ganhos ao fim de cada Descida (GDD §9, §26) eram apenas exibidos e salvos em `meta.json` (`SaveStore`), sem um lugar para gastá-los. O GDD §9 define o **Santuário** como o menu estilo acampamento entre Descidas, dividido no MVP em **Biblioteca**, **Arsenal** e **Códice (Bestiário)**, com a regra de segurança de que bônus numéricos permanentes somam no máximo +10% (priorizando variedade e preparação tática em vez de inflação de atributos).

## Decisão

1. **Catálogo puro do Santuário (`SanctuaryRules` em `game/core/run/sanctuary_rules.gd`)**:
   - **Biblioteca**:
     - `tome_of_fury` (*Tomo do Grito de Guerra*, 12 Ecos): a Bibiana inicia a Descida já com a skill `war_cry` (*Grito de Guerra*) aprendida no grimório.
     - `tome_of_edge` (*Manual do Fio Afiado*, 16 Ecos): descansar ou usar skill em fogueira acesa concede automaticamente o buff `sharpen_edge` (+10 de CRIT por 2 combates).
   - **Arsenal**:
     - `blessing_iron_skin` (*Bênção da Malha Antiga*, 15 Ecos): bônus numérico permanente de +8% no HP máximo e +8% na DEF base (dentro do teto de +10% do GDD §9).
     - `pack_of_provisions` (*Fardo do Viajante*, 18 Ecos): a Bibiana inicia a Descida com +35 moedas de ouro e 1 `dirty_ether` (*Éter Sujo*) extra na mochila.
   - **Códice (Bestiário)**:
     - Lista todos os 7 inimigos de `enemies.json` (`infected_citizen`, `giant_rat`, `carrion_crow`, `plague_hound`, `rotted_executioner`, `bell_warden`, `gravedigger`), exibindo tipo, nível base, medo/hábito, golpe de moeda temático (e consequência da coroa), reação e o histórico acumulado de vitórias (`kills`) e quedas da Bibiana (`deaths`) contra cada um.
2. **Isolamento do `RunState` padrão**:
   - `RunState.new(..., meta_unlocks: Array = [])` recebe a lista de IDs desbloqueados como parâmetro opcional (padrão `[]`). Assim, todas as sementes de teste e simulações sem meta-progresso permanecem 100% determinísticas e inalteradas.
   - `RunState` registra em `defeated_enemy_ids` o `enemy_id` de cada vitória da Descida; ao terminar a Descida em `GameScreen._show_result()`, o Bestiário soma as vitórias de `defeated_enemy_ids` e, em caso de derrota, incrementa `deaths` para `killer_enemy_id`.
3. **Persistência retrocompatível (`SaveStore`)**:
   - `SaveStore.save_meta(echoes, runs_played, unlocks = [], bestiary = {})` grava os novos campos em `meta.json` sem quebrar chamadas existentes de 2 argumentos.
4. **Versão de regras**:
   - `CoreVersion.RULES_VERSION` sobe de `16` para `17`. Conforme diretriz de foco no MVP jogável registrada no `HANDOFF.md` e `CLAUDE.md`, não executamos rodadas longas do simulador de balanceamento nesta etapa.

## Consequências

- Os Ecos passam a ter utilidade imediata após a 1ª Descida (que já concede Ecos em dobro pela `ADR-0031`), fechando o loop de meta-progresso do GDD §9.
- O Códice transforma a "morte que ensina" em memória permanente entre sessões, permitindo ao jogador consultar o golpe de moeda e a reação de cada inimigo antes de iniciar outra Descida.
