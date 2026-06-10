#!/usr/bin/env bash
# =============================================================================
# Warp Terminal Native Theme Installer - SovietWave
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
GITHUB_BASE_URL="https://raw.githubusercontent.com/victorcrbt/sovietwave/main/terminals/warp"
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WARP_THEMES_DIR="$HOME/.warp/themes"

RED='\033[0;31m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "\n${RED}╔══════════════════════════════════════════╗${RESET}"
echo -e "${RED}║${CYAN}   🌊  SOVIETWAVE — Warp Theme Installer  ${RED}║${RESET}"
echo -e "${RED}╚══════════════════════════════════════════╝${RESET}\n"

# 1. Escolha da variante
echo -e "Qual variante você deseja instalar?"
echo -e "  1) SovietWave (Base)"
echo -e "  2) SovietWave - Zhukov"
read -r -p "Escolha [1/2]: " VARIANT_CHOICE < /dev/tty

if [ "$VARIANT_CHOICE" == "2" ]; then
  THEME_FILENAME="sovietwave-zhukov.yaml"
  THEME_NAME="SovietWave Zhukov"
else
  THEME_FILENAME="sovietwave.yaml"
  THEME_NAME="SovietWave"
fi

THEME_FILE="$SCRIPT_DIR/$THEME_FILENAME"

echo -e "${CYAN}→ Criando diretório de temas do Warp (se não existir)...${RESET}"
mkdir -p "$WARP_THEMES_DIR"

# 2. Obter o tema e instalar
if [ -f "$THEME_FILE" ]; then
  echo -e "${CYAN}→ Usando tema local: $THEME_FILENAME${RESET}"
  cp "$THEME_FILE" "$WARP_THEMES_DIR/"
else
  echo -e "${YELLOW}→ Tema local não encontrado. Baixando do GitHub...${RESET}"
  if ! curl -sfL "$GITHUB_BASE_URL/$THEME_FILENAME" -o "$WARP_THEMES_DIR/$THEME_FILENAME"; then
    echo -e "${RED}✗ Falha ao baixar o tema. Verifique a URL: $GITHUB_BASE_URL/$THEME_FILENAME${RESET}"
    exit 1
  fi
fi

echo -e "\n${GREEN}╔═════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ✓ Tema $THEME_NAME instalado com sucesso!   ║${RESET}"
echo -e "${GREEN}╚═════════════════════════════════════════════════════════╝${RESET}\n"
echo -e "  Para aplicar, abra o Warp Terminal e vá em:"
echo -e "  ${BOLD}Settings -> Appearance -> Themes${RESET}"
echo -e "  Pesquise por '$THEME_NAME' e selecione.\n"
