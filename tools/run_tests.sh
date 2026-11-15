#!/usr/bin/env bash
# Roda a suite GUT em modo headless com um comando.
# Uso: bash tools/run_tests.sh [opcoes do GUT, ex.: -gtest=res://tests/unit/test_x.gd]
# O Godot vem de $GODOT_BIN ou do PATH (godot, godot4).
# Codigo de saida: 0 = suite verde, 1 = falha em teste, 2 = ambiente incompleto.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=versions.env
source "$ROOT/tools/versions.env"

GODOT="${GODOT_BIN:-}"
if [[ -z "$GODOT" ]]; then
	for candidate in godot godot4; do
		if command -v "$candidate" > /dev/null 2>&1; then
			GODOT="$candidate"
			break
		fi
	done
fi
if [[ -z "$GODOT" ]]; then
	echo "ERRO: Godot nao encontrado. Instale o Godot $GODOT_MINOR e defina GODOT_BIN com o caminho do executavel." >&2
	exit 2
fi

bash "$ROOT/tools/setup.sh"

VERSION="$("$GODOT" --version | head -n 1)"
case "$VERSION" in
	"$GODOT_MINOR".*) ;;
	*) echo "AVISO: Godot $VERSION em uso; o projeto fixa $GODOT_MINOR.x (tools/versions.env)." >&2 ;;
esac

# O import gera .godot/ e registra os class_name; sem ele o GUT nao acha as classes.
echo "== Importando o projeto =="
IMPORT_LOG="$(mktemp)"
if ! "$GODOT" --headless --path "$ROOT" --import > "$IMPORT_LOG" 2>&1; then
	echo "AVISO: o import terminou com erro. Fim do log:" >&2
	tail -n 30 "$IMPORT_LOG" >&2
fi
rm -f "$IMPORT_LOG"

echo "== Rodando os testes (GUT $GUT_VERSION, Godot $VERSION) =="
"$GODOT" --headless --path "$ROOT" -s addons/gut/gut_cmdln.gd -gexit "$@"
