# TASK-054: conceito visual Nano Banana no talo e dossiê 3D do Roaming Boss (`O Perseguidor Coroado`)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (conceito visual em 4+1 pranchas e dossiê técnico concluídos; aguarda revisão do Orlando antes da modelagem 3D e do código Nemesis) |
| Aberta em | 2026-11-21 |
| Fase | 1–3, pré-produção de inimigos e sistema Nemesis (GDD §13, §18) |
| GDD | 6, 7, 11, 13, 17, 18, 19 |
| ADRs | ADR-0036, ADR-0042 |

## Objetivo

Produzir com o gerador de imagens (`image-generator` / Nano Banana) em qualidade máxima o pacote visual completo e o dossiê de reconstrução 3D + mecânica do **Roaming Boss** do jogo (**O Perseguidor Coroado**, arquétipo Nemesis do GDD §13), unindo armadura gótica negra coberta de crânios em decomposição expondo carne podre, maça brutal em uma mão e espada pesada quebrada ao meio super afiada na outra, sob o cânone obrigatório do `ADR-0042`.

## Fora do escopo

- Gerar ou alterar o arquivo `.glb` final no Blender ou TRELLIS.2 nesta tarefa (entra após OK visual do Orlando).
- Alterar `game/core/`, `game/data/enemies.json`, `docs/enemies/ENEMY-*.md`, `tools/` ou `CoreVersion.RULES_VERSION` (`20`) para implementar a lógica de perseguição/Nemesis em runtime.

## Critérios de aceite

- [x] Exploração de Key Art Mestre com múltiplas candidatas e portão de inspeção visual via `read_file` garantindo todos os elementos pedidos por Orlando (coroa/elmo gótico pontiagudo, armadura negra com crânios humanos, armadura desmanchando com carne podre exposta, maça brutal na mão direita e espada quebrada ao meio super afiada na mão esquerda).
- [x] Pacote coeso completo salvo em `docs/design/refs/roaming-boss/`: Key Art Mestre (`01` + variação alternativa `01b`), Turnaround 3D Frente/3/4/Costas (`02`), Folha de Ultra-Detalhes de armadura/armas (`03`) e Diorama de Combate Retrato `9:16` aderente ao `ADR-0042` (`04`).
- [x] Zero citações de nomes de jogos, personagens ou artistas reais dentro dos prompts usados no gerador de imagens (`GDD §18`, `ADR-0042` §4).
- [x] Dossiê completo em `docs/design/ROAMING-BOSS-perseguidor-coroado.md` com galeria embutida, conferência visual, progressão Nemesis (5 patentes), proposta de combate/moeda e spec YAML IA-friendly para TRELLIS.2 / Blender (`<= 8000` tris para chefe).
- [x] Artifact visual `roaming_boss_showcase.md` criado para inspeção direta do Orlando, `docs/FEEDBACK.md` (`F-023`) e `docs/HANDOFF.md` atualizados, encoding UTF-8/LF verificado e suíte GUT verde.

## Arquivos afetados

- `docs/design/ROAMING-BOSS-perseguidor-coroado.md`
- `docs/design/refs/roaming-boss/01-perseguidor-coroado-key-art.jpg`
- `docs/design/refs/roaming-boss/01b-perseguidor-coroado-key-art-alt.jpg`
- `docs/design/refs/roaming-boss/02-perseguidor-coroado-turnaround.jpg`
- `docs/design/refs/roaming-boss/03-perseguidor-coroado-detalhes-armas.jpg`
- `docs/design/refs/roaming-boss/04-perseguidor-coroado-combate-diorama.jpg`
- `docs/tasks/TASK-054-roaming-boss-conceito-nano-banana.md`
- `docs/FEEDBACK.md`
- `docs/HANDOFF.md`

## Testes esperados

- Auditoria em Python confirmando 100% de existência e integridade JPEG (`magic bytes` + tamanho) das 5 imagens referenciadas no dossiê, além de UTF-8 sem BOM, LF e ausência de mojibake em todos os `.md`.
- Suíte headless (`powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1`), incluindo `tests/unit/test_project_standards.gd` validando sequência contínua até `TASK-054`, seções exigidas, `Verificação` preenchida e `HANDOFF.md` com `RULES_VERSION = 20`.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR.
- Núcleo sem nós e sem aleatoriedade global.
- Seguir obrigatoriamente `docs/ART-DIRECTION.md` e o `ADR-0042` (craft/profundidade de *Sword of Convallaria*, *Tactics Ogre*, *Triangle Strategy*, *Octopath Traveler*, *Ragnarok Online* e *Buriedbornes* sob atmosfera dark gótica de *Bloodborne* e *Dark Souls*; prompts de IA sem nomes de jogos, GDD §18).

## Verificação

- **Inspeção visual direta (`read_file`):** todas as 5 pranchas geradas (`01`, `01b`, `02`, `03`, `04`) foram inspecionadas visualmente quanto à espada claramente partida ao meio e afiada, maça de seis abas, crânios esculpidos na armadura negra, ruptura/carne podre exposta, consistência entre Frente/3/4/Costas, ausência de texto borrado e aderência ao diorama dark gótico do `ADR-0042`.
- **Auditoria de links e encoding (Python) em 2026-11-22:** validados cabeçalhos JPEG e tamanhos das 5 imagens em `docs/design/refs/roaming-boss/` (`100%` presentes e íntegras), bem como UTF-8 sem BOM, LF e zero mojibake nos arquivos `.md` criados/editados.
- **Suíte headless (`powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1`) em 2026-11-22:** `353/353` testes passando em `49` scripts (`57533` asserts, exit `0`), incluindo `test_project_standards.gd` (`7/7`).

**Não exercitado em execução de jogo:** tarefa puramente conceitual e de pré-produção visual (sem mudança em cenas 3D ou código GDScript); a modelagem `.glb` e a integração Nemesis ficam para tarefas seguintes após o OK do Orlando.

## Revisão cruzada

Pendente.
