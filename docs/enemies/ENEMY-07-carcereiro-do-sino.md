# ENEMY-07: Carcereiro do Sino

| Campo | Valor |
| --- | --- |
| Id (dados) | `bell_warden` |
| Tipo e nível | mini_boss, nível base 4 |
| Cenário | Cidade Abandonada |
| Medo | Ouvir o sino rachado no começo do cenário e decidir se vale cruzar o caminho dele pelo prêmio raro. |

## Fantasia

Carrega nas costas a jaula-sino de ferro que trancava os quarentenados na praça. Quando ele aparece no mapa, o sino rachado toca à distância e marca a rota em vermelho. O combate não permite fuga (GDD §13): quem entra na praça do Carcereiro aceitou o julgamento.

## Mecânica assinatura

- **Golpe de moeda: Badalo Ensurdecedor (`deafening_toll`, Cruel).** Em cara o dano cai 50%; em coroa o dano dobra e o estrondo deixa a Bibiana com **Cegueira** (PRE -30% por 3 turnos).
- **Golpe de debuff: Repique Fúnebre (`toll_curse`, debuff 65%).** Causa dano e tem 65% de chance (cortada pela metade se Defender) de aplicar **Fraqueza** (ATK -25% por 3 turnos).
- **Reação:** se o jogador Defender duas vezes seguidas, ele responde com **Golpe de Jaula (`cage_slam`, forte 1,45×)** ("Cansou de esperar sua guarda"); abaixo de 40% da própria vida, força o **Repique Fúnebre** ("Está acuado").
- **Contra-jogo:** guardar Defender para o Badalo Ensurdecedor e o Repique Fúnebre (não defender em turnos vazios para não acionar o Golpe de Jaula) e explorar a fraqueza a Raio e Sagrado (×1,5).

## Ciclo e números

Ataque, Badalo Ensurdecedor (moeda Cruel), Repique Fúnebre (debuff), Golpe de Jaula (forte 1,45×), Ataque. Vida 125, FOR 16, DEF 10, RES 6, VEL 6, ESQ 3. Fraco a Raio (1,5) e Sagrado (1,5); resistente a Sombra (0,5). Não permite fuga.

## Drops e textos

Mini boss (GDD §5, §10, §12 e §13; ADR-0033): Poder ×2,5, ouro ×2,5, **equipamento raro garantido (100%)**, **Galhos Secos garantidos (100%)** e **Moeda da Sorte garantida (100%)**. Aviso: "MOEDA Badalo Ensurdecedor. Acertar: dano -50%. Errar: dano +100% e Cegueira por 3 turnos".

## Regras que a ficha não pode quebrar

- Golpe perigoso avisado; ao menos 2 golpes entre golpes de moeda; sem Golpe Mortal (só chefe); opcional no mapa (sempre existe rota alternativa).
