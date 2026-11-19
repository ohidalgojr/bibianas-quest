# TASK-014: exportação Web e Android e teste no celular

| Campo | Valor |
| --- | --- |
| Status | Em verificação: presets, script e guia prontos; falta instalar os templates, exportar e jogar 20 minutos no celular (Orlando) |
| Aberta em | 2026-11-16 |
| Fase | 1, portão da Fase 1 |
| GDD | 20 (exportação, toque), 22 |
| ADRs | ADR-0019 |

## Objetivo

Um build Web para o link de playtest, um preset Android de um clique e a primeira sessão de 20 minutos no celular, com a lista de problemas.

## Fora do escopo

- Publicar em loja, assinatura de lançamento, hospedagem definitiva do link, iOS.

## Critérios de aceite

- [x] `export_presets.cfg` com os presets Web e Android, incluindo `game/data/*.json` e deixando de fora docs, testes e ferramentas.
- [x] `emulate_touch_from_mouse` desligado em Android e Web (GDD §20).
- [x] `tools\export_web.ps1` exporta e, com `-Serve`, serve em localhost.
- [x] `docs/PLAYTEST.md` com pré-requisitos, exportação e a ficha da sessão de 20 minutos.
- [ ] Templates instalados e Web exportado e aberto no navegador. **Orlando** (os templates não estão instalados).
- [ ] APK instalado no celular. **Orlando** (precisa de JDK e Android SDK).
- [ ] Sessão de 20 minutos feita e a ficha preenchida. **Orlando**.

## Arquivos afetados

- `export_presets.cfg`, `project.godot`, `tools/export_web.ps1`, `docs/PLAYTEST.md`
- `docs/adr/ADR-0019-exportacao.md`

## Verificação

2026-11-16: suíte 222/222 depois das mudanças. A exportação em si **não foi executada**: não há templates de exportação nesta máquina, então os presets não foram testados e podem pedir ajuste no primeiro uso, principalmente o Android.

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §2, §22 e `ADR-0019`**: `export_presets.cfg` versionado sem segredos nem caminhos locais de keystore, com orientação retrato (`screen/orientation=0`) e `tools/export.ps1` documentando os comandos e variáveis de ambiente.
- **Achados**: nenhum achado crítico ou importante. Aprovada.
