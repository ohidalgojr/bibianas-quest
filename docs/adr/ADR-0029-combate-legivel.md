# ADR-0029: combate legível, crítico manipulável e MP

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-18 |
| Tarefa | TASK-024 |
| GDD | 6, 8, 10, 12 |

## Contexto

D6 do ADR-0025 e F-007, F-008, F-011 do playtest: o MP do Guerreiro estava curto, as skills não tinham descrição nem números, o Orlando queria ver a faixa de dano e a chance de acerto (como em Darkest Dungeon), e o crítico devia ficar visível e manipulável por eventos de mapa, skills e itens.

## Decisão

1. **Previsão sem sorteio:** `Combat.preview_player_strike(power)` devolve dano mínimo e máximo (sem crítico), dano máximo com crítico, chance de acerto (PRE contra ESQ) e chance de crítico. Não mexe em nenhum fluxo de RNG, então a previsão nunca muda o resultado da luta. Um teste confere que todo golpe real cai dentro da faixa.
2. **Botões com números:** Atacar e as skills de dano mostram "dano 12-16 · acerto 90% · crít 5%"; skills sem dano mostram o efeito ("cura 32 de HP", "DEF +50% e reflete 20%"). A dica de cada skill traz a descrição completa. Os números vêm do motor, nunca repetidos na tela.
3. **MP:** atacar devolve 10% do MP máximo (`ATTACK_MP_RETURN`, igual ao Defender) e o **Éter Sujo** ganha um botão no combate (restaura 50% do MP) e entra no drop de consumíveis. Somados, o Guerreiro usa skills com mais folga sem mudar o MP máximo.
4. **Crítico (D6):** a mecânica não muda (CRIT, dano ×1,5). Fica visível (chance na previsão, "CRÍTICO!" em número maior) e manipulável por item (Garra Afiada, relíquia, CRIT +8) e por skill de fogueira (Afiar o Fio, CRIT +10 pontos por 3 combates). Evento de mapa que mexa no crítico fica para quando houver eventos (hoje o peso de evento é 0).
5. **Coveiro:** HP 205 → 195 (FOR 16). Com mais MP e crítico o jogador chega mais forte, e com 205 um mapa em 30 ficava sem rota vencível.
6. `RULES_VERSION` sobe para 12.

## Verificação no simulador

Regras v12, 150 Descidas por bot, 40 mapas com 40 simulações (`reports/simulation.md`, 2026-11-18): Coveiro 195/16 dá mediano 70,7% (meta 55% a 65%), cuidadoso 82,0%, mortes por moeda 13,6%, 0 de 40 mapas sem rota vencível, 1,2 s para criar a Descida. Com 205/16: mediano 62,0%, mas 1 de 30 mapas sem rota vencível (viola o GDD §5), por isso o Coveiro ficou em 195. Os bots não usam o Éter nem as skills novas com critério, então o ganho real deve ser maior.

## Alternativas

- **Previsão em janela de detalhes:** no celular não há "passar o mouse"; texto no botão lê-se de relance.
- **Mais MP máximo com o Poder:** muda o GDD §9 e aumenta o poder do jogador de forma mais difícil de calibrar; atacar devolver MP resolve o gargalo sem isso.
