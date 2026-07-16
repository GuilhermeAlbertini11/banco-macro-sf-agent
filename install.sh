#!/bin/bash
set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   Banco Macro MDA — Setup do Agente Claude       ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""

ok()  { echo -e "  ${GREEN}✓${RESET} $1"; }
warn(){ echo -e "  ${YELLOW}⚠${RESET}  $1"; }
info(){ echo -e "  ${BOLD}→${RESET} $1"; }
fail(){ echo -e "  ${RED}✗${RESET} $1"; exit 1; }

# ── 1. Node.js ──────────────────────────────────────────────────────────────
info "Verificando Node.js..."
if command -v node &>/dev/null; then
  ok "Node.js $(node --version) encontrado"
else
  warn "Node.js não encontrado. Instalando via Homebrew..."
  if ! command -v brew &>/dev/null; then
    fail "Homebrew não encontrado. Instale em https://brew.sh e rode este script novamente."
  fi
  brew install node
  ok "Node.js instalado"
fi

# ── 2. Claude Code CLI ───────────────────────────────────────────────────────
info "Verificando Claude Code CLI..."
if command -v claude &>/dev/null; then
  ok "Claude Code $(claude --version 2>/dev/null || echo '') encontrado"
else
  warn "Claude Code não encontrado. Instalando..."
  npm install -g @anthropic/claude-code
  ok "Claude Code instalado"
fi

# ── 3. Salesforce CLI ────────────────────────────────────────────────────────
info "Verificando Salesforce CLI (sf)..."
if command -v sf &>/dev/null; then
  ok "sf CLI $(sf --version 2>/dev/null | head -1) encontrado"
else
  warn "sf CLI não encontrado. Instalando..."
  npm install -g @salesforce/cli
  ok "sf CLI instalado"
fi

# ── 4. Plugin setup-agents ───────────────────────────────────────────────────
info "Verificando plugin @jterrats/setup-agents..."
if sf plugins inspect @jterrats/setup-agents &>/dev/null 2>&1; then
  ok "Plugin setup-agents já instalado"
else
  warn "Instalando plugin setup-agents..."
  sf plugins install @jterrats/setup-agents@3.15.0-rc
  ok "Plugin setup-agents instalado"
fi

# ── 5. Variável ANTHROPIC_API_KEY ────────────────────────────────────────────
info "Verificando ANTHROPIC_API_KEY..."
if [ -n "$ANTHROPIC_API_KEY" ]; then
  ok "ANTHROPIC_API_KEY configurada"
else
  warn "ANTHROPIC_API_KEY não encontrada no ambiente."
  echo ""
  echo -e "  Adicione no seu ${BOLD}~/.zshrc${RESET} ou ${BOLD}~/.bashrc${RESET}:"
  echo -e "  ${YELLOW}export ANTHROPIC_API_KEY=\"sk-ant-...\"${RESET}"
  echo ""
  echo -e "  Obtenha sua chave em: ${BOLD}https://console.anthropic.com${RESET}"
fi

# ── Resumo ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  Setup concluído!${RESET}"
echo ""
echo -e "  Para iniciar o agente, abra esta pasta no Claude Code:"
echo -e "  ${BOLD}claude${RESET}"
echo ""
echo -e "  Ou via VS Code / Cursor com a extensão Claude Code."
echo -e "${BOLD}══════════════════════════════════════════════════${RESET}"
echo ""
