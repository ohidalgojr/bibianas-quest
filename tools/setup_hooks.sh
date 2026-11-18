#!/bin/sh
# Liga os hooks de git do projeto (.githooks). Rode uma vez por clone ou worktree.
# Para desligar: git config --unset core.hooksPath
root=$(git rev-parse --show-toplevel)
cd "$root" || exit 1
git config core.hooksPath .githooks
chmod +x .githooks/commit-msg .githooks/pre-commit 2>/dev/null
echo "Hooks ligados: core.hooksPath = .githooks"
