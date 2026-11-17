# ADR-0024: skills de combate na loja

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-16 |
| Tarefa | TASK-020 |
| GDD | 8, 15 |

## Contexto

Pedido do Orlando (F-004): novas magias (skills) na loja, como mecânica básica de roguelike RPG. O GDD §15 já prevê um item especial na loja, que pode ser "skill rara".

## Decisão

1. **O item especial da loja é uma skill de combate** da classe que o jogador ainda não tem, sorteada no fluxo de loot ao abrir a loja. Uma por visita; a oferta some ao comprar ou sair. O reroll não troca a skill.
2. **Espaços:** até 5 skills por Descida (`RunRules.MAX_SKILLS`): as 3 iniciais e 2 compradas.
3. **Três skills do Guerreiro** (valores do protótipo): Golpe Giratório (5 MP, 1,3×FOR, 120 moedas), Grito de Guerra (4 MP, FOR e MEN +25% por 3 turnos, 100) e Segundo Fôlego (6 MP, cura 25% do HP máximo, 140). Nos dados, `price` zero marca as iniciais.
4. **Motor:** efeitos `power_strike`, `war_cry` (efeito `EMPOWERED`, inverso da Fraqueza) e `mend`.
5. **Save:** `learned_skills` no `RunSave`; save sem o campo cai nas skills iniciais da classe.
6. **Bots:** compram a skill se sobrarem 30 de ouro e as usam; o cuidadoso continua com o Golpe de Escudo no chefe.
7. `RULES_VERSION` sobe para 8.

## Verificação no simulador

150 Descidas por bot, regras v8: mediano 65,3% (era 65,0%), cuidadoso 80,7%, mortes por moeda 19,2%, 0 mapas sem rota vencível em 100. As skills mal mudam os bots, que gastam o ouro em itens antes; o efeito real deve aparecer em quem joga. Sem recalibração do Coveiro.

## Alternativas

- **Trocar uma skill por outra (esquecer):** mais decisão, mais tela; fica para depois.
- **Mais de uma skill por visita ou skill na recompensa:** pode vir com a Biblioteca do Santuário (GDD §9).
- **MP:** o Guerreiro tem 20 de MP e não ganha MP com o Poder. As skills novas custam pouco para caber, mas o MP segue curto; Éter Sujo ainda não tem uso em combate. Candidato a próxima tarefa.
