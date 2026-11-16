# Playtest no celular e na web

Guia da TASK-014 (portão da Fase 1). O que depende de instalação na máquina do Orlando está marcado.

## 1. Pré-requisitos (uma vez)

1. **Templates de exportação do Godot 4.7.2:** Editor > Projeto > Exportar > "Gerenciar templates de exportação" > Baixar e instalar. *(Orlando: o PC ainda não tem; `%APPDATA%\Godot\export_templates` está vazio.)*
2. **Web:** só isso, mais `python` no PATH se quiser o servidor local.
3. **Android:** JDK 17, Android SDK (platform-tools, build-tools 34, platform 34) e uma debug keystore; configure os caminhos em Editor > Configurações do editor > Exportar > Android. Ative a depuração USB no celular.

## 2. Exportar

- **Web:** `powershell -ExecutionPolicy Bypass -File tools\export_web.ps1 -Serve` e abra http://localhost:8060. Para compartilhar o link de playtest, publicar a pasta `build\web` em qualquer hospedagem estática (a escolha da hospedagem é do Orlando).
- **Android:** no editor, Projeto > Exportar > Android > "Executar com um clique" com o celular ligado por USB, ou exporte o APK de depuração.
- Os atalhos de depuração (F1 a F4, semente) só existem em build de depuração. Para o teste de sensação, exporte em modo **release**: o jogo fica como o jogador vê.
- `pointing/emulate_touch_from_mouse` já fica desligado em Android e Web (`project.godot`, override por plataforma), para não duplicar o toque no celular.
- Os `.json` de `game/data/` entram pelo filtro de inclusão dos presets; sem eles o jogo abre sem dados.

## 3. Sessão de 20 minutos no celular (critério de aceite)

Jogar de ponta a ponta sem ajuda, em retrato: menu, Descida, lutas, loja, fogueira, morte ou vitória, "Outra Descida". Anotar enquanto joga, e depois preencher:

| Pergunta | Resposta |
| --- | --- |
| Aparelho, Android, navegador |  |
| Cada botão é fácil de tocar com o polegar (zona de ação, mapa, loja)? |  |
| Algum texto cortado ou pequeno demais? |  |
| A criação da Descida (cerca de 1,5 s no PC) trava quanto tempo no celular? |  |
| A escolha de Cara ou Coroa e o giro de 1,2 s dão tensão? |  |
| O aviso de um turno antes do golpe de moeda basta? |  |
| Quedas de quadro, travadas, erros? |  |
| Fechar o app no meio e "Continuar Descida" funcionou? |  |
| Descidas jogadas em 20 minutos, vitórias, mortes por moeda |  |

Problemas encontrados vão para `docs/FEEDBACK.md` (sensação e design) ou viram tarefa (defeito).
