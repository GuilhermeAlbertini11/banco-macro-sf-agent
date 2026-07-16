#!/bin/bash
set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"
REPO="https://github.com/GuilhermeAlbertini11/banco-macro-sf-agent.git"
DIR="$HOME/banco-macro-sf-agent"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   Banco Macro MDA — Setup do Agente Claude       ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""

ok()  { echo -e "  ${GREEN}✓${RESET} $1"; }
warn(){ echo -e "  ${YELLOW}→${RESET} $1"; }
fail(){ echo -e "  ${RED}✗${RESET} $1"; exit 1; }

# ── Homebrew ─────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  warn "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
ok "Homebrew OK"

# ── Node.js ───────────────────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  warn "Instalando Node.js..."
  brew install node
fi
ok "Node.js $(node --version)"

# ── Claude Code CLI ───────────────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
  warn "Instalando Claude Code..."
  npm install -g @anthropic/claude-code
fi
ok "Claude Code OK"

# ── Salesforce CLI ────────────────────────────────────────────────────────────
if ! command -v sf &>/dev/null; then
  warn "Instalando sf CLI..."
  npm install -g @salesforce/cli
fi
ok "sf CLI OK"

# ── Plugin setup-agents ───────────────────────────────────────────────────────
if ! sf plugins inspect @jterrats/setup-agents &>/dev/null 2>&1; then
  warn "Instalando plugin setup-agents..."
  sf plugins install @jterrats/setup-agents@3.15.0-rc
fi
ok "Plugin setup-agents OK"

# ── Clonar repo ───────────────────────────────────────────────────────────────
if [ -d "$DIR/.git" ]; then
  warn "Atualizando repositório existente..."
  git -C "$DIR" pull --quiet
else
  warn "Clonando repositório..."
  git clone --quiet "$REPO" "$DIR"
fi
ok "Repositório em $DIR"

# ── ANTHROPIC_API_KEY ─────────────────────────────────────────────────────────
SHELL_RC="$HOME/.zshrc"
[ -n "$BASH_VERSION" ] && SHELL_RC="$HOME/.bashrc"

if [ -z "$ANTHROPIC_API_KEY" ] || ! grep -q "ANTHROPIC_API_KEY" "$SHELL_RC" 2>/dev/null; then
  echo ""
  echo -e "  ${BOLD}Cole sua Anthropic API Key${RESET} (console.anthropic.com → API Keys):"
  echo -n "  sk-ant-... > "
  read -r API_KEY
  if [ -n "$API_KEY" ]; then
    echo "" >> "$SHELL_RC"
    echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> "$SHELL_RC"
    export ANTHROPIC_API_KEY="$API_KEY"
    ok "API Key salva em $SHELL_RC"
  fi
else
  ok "ANTHROPIC_API_KEY já configurada"
fi

# ── Pronto ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}  ✓ Tudo pronto!${RESET}"
echo ""
echo -e "  Rode o agente com:"
echo -e "  ${BOLD}cd $DIR && claude${RESET}"
echo ""
