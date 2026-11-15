#!/usr/bin/env bash
# Instala o GUT na versao fixada em tools/versions.env (ADR-0003). Idempotente.
# Uso: bash tools/setup.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=versions.env
source "$ROOT/tools/versions.env"

DEST="$ROOT/addons/gut"
STAMP="$DEST/.gut_version"

if [[ -f "$STAMP" && "$(cat "$STAMP")" == "$GUT_VERSION" ]]; then
	echo "GUT $GUT_VERSION ja instalado."
	exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

URL="https://github.com/bitwes/Gut/archive/refs/tags/v${GUT_VERSION}.zip"
echo "Baixando GUT $GUT_VERSION..."
curl -fsSL "$URL" -o "$TMP/gut.zip"
unzip -q "$TMP/gut.zip" -d "$TMP"

SRC="$(find "$TMP" -maxdepth 3 -type d -path '*/addons/gut' | head -n 1)"
if [[ -z "$SRC" ]]; then
	echo "ERRO: addons/gut nao encontrado no pacote baixado." >&2
	exit 1
fi

rm -rf "$DEST"
mkdir -p "$ROOT/addons"
cp -R "$SRC" "$DEST"
printf '%s' "$GUT_VERSION" > "$STAMP"
echo "GUT $GUT_VERSION instalado em addons/gut."
