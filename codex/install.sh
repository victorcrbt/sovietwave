#!/usr/bin/env bash
# =============================================================================
# Codex Native Theme Installer - SovietWave
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
GITHUB_BASE_URL="https://raw.githubusercontent.com/victorcrbt/sovietwave/main/codex"
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_CONFIG="$HOME/.codex/config.toml"

RED='\033[0;31m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "\n${RED}╔══════════════════════════════════════════╗${RESET}"
echo -e "${RED}║${CYAN}   🌊  SOVIETWAVE — Codex Theme Installer ${RED}║${RESET}"
echo -e "${RED}╚══════════════════════════════════════════╝${RESET}\n"

# 1. Escolha da variante
echo -e "Qual variante você deseja instalar?"
echo -e "  1) SovietWave (Base)"
echo -e "  2) SovietWave - Zhukov"
read -r -p "Escolha [1/2]: " VARIANT_CHOICE < /dev/tty

if [ "$VARIANT_CHOICE" == "2" ]; then
  THEME_FILENAME="sovietwave-zhukov.json"
else
  THEME_FILENAME="sovietwave.json"
fi

THEME_FILE="$SCRIPT_DIR/$THEME_FILENAME"

# 2. Obter o tema
if [ -f "$THEME_FILE" ]; then
  echo -e "${CYAN}→ Usando tema local: $THEME_FILENAME${RESET}"
  THEME_CONTENT=$(cat "$THEME_FILE")
else
  echo -e "${YELLOW}→ Tema local não encontrado. Baixando do GitHub...${RESET}"
  if ! curl -sfL "$GITHUB_BASE_URL/$THEME_FILENAME" -o /tmp/codex_theme.json; then
    echo -e "${RED}✗ Falha ao baixar o tema. Verifique a URL: $GITHUB_BASE_URL/$THEME_FILENAME${RESET}"
    exit 1
  fi
  THEME_CONTENT=$(cat /tmp/codex_theme.json)
fi

# 3. Escolha do Modo de Instalação
echo -e "\n${CYAN}Como deseja aplicar o tema?${RESET}"
echo -e "  1) Injetar automaticamente no Codex (pode sobrescrever configs visuais)"
echo -e "  2) Copiar para a Área de Transferência (Para importar manualmente na UI)"
read -r -p "Escolha [1/2]: " MODE_CHOICE < /dev/tty

if [ "$MODE_CHOICE" == "2" ]; then
  echo -n "$THEME_CONTENT" | pbcopy
  echo -e "\n${GREEN}╔═════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${GREEN}║  ✓ Tema copiado para o clipboard!                       ║${RESET}"
  echo -e "${GREEN}╚═════════════════════════════════════════════════════════╝${RESET}"
  echo -e "  Vá no Codex -> Settings -> Appearance -> Import e cole."
  exit 0
fi

# Extrair JSON para a injeção
if [[ "$THEME_CONTENT" == codex-theme-v1:* ]]; then
  THEME_JSON="${THEME_CONTENT#codex-theme-v1:}"
else
  THEME_JSON="$THEME_CONTENT"
fi

if ! command -v node &>/dev/null; then
  echo -e "${RED}✗ Node.js não encontrado. Necessário para injetar o tema.${RESET}"
  exit 1
fi

if [ ! -f "$CODEX_CONFIG" ]; then
  echo -e "${RED}✗ Arquivo de configuração não encontrado: $CODEX_CONFIG${RESET}"
  exit 1
fi

if pgrep -x Codex &>/dev/null; then
  echo -e "${CYAN}→ Fechando o Codex para aplicar configurações...${RESET}"
  pkill -x Codex || true
  sleep 2
fi

echo -e "${CYAN}→ Injetando tema diretamente no config.toml...${RESET}"

node - <<EOF
const fs = require('fs');
const path = require('path');

const configPath = '$CODEX_CONFIG';
const themeJson = JSON.parse(\`$THEME_JSON\`);
let tomlLines = fs.readFileSync(configPath, 'utf8').split('\n');

// 1. Atualizar chaves na raiz do [desktop]
let inDesktop = false;
let foundTheme = false;
let foundCodeThemeId = false;

for (let i = 0; i < tomlLines.length; i++) {
  const line = tomlLines[i].trim();
  if (line === '[desktop]') inDesktop = true;
  else if (line.startsWith('[')) inDesktop = false;

  if (inDesktop) {
    if (line.startsWith('appearanceTheme')) {
      tomlLines[i] = \`appearanceTheme = "\${themeJson.variant}"\`;
      foundTheme = true;
    }
    if (line.startsWith('appearanceDarkCodeThemeId')) {
      tomlLines[i] = \`appearanceDarkCodeThemeId = "\${themeJson.codeThemeId}"\`;
      foundCodeThemeId = true;
    }
  }
}

if (!foundTheme) tomlLines.splice(1, 0, \`appearanceTheme = "\${themeJson.variant}"\`);
if (!foundCodeThemeId) tomlLines.splice(1, 0, \`appearanceDarkCodeThemeId = "\${themeJson.codeThemeId}"\`);

// 2. Remover qualquer bloco antigo do appearanceDarkChromeTheme e sub-blocos
let newLines = [];
let inChromeTheme = false;
for (let line of tomlLines) {
  if (line.trim().startsWith('[desktop.appearanceDarkChromeTheme')) {
    inChromeTheme = true;
    continue;
  }
  if (inChromeTheme && line.trim().startsWith('[')) {
    inChromeTheme = false;
  }
  if (!inChromeTheme) {
    newLines.push(line);
  }
}

let toml = newLines.join('\n');

// 3. Montar bloco TOML do tema
const t = themeJson.theme;
const themeToml = \`
[desktop.appearanceDarkChromeTheme]
accent = "\${t.accent}"
contrast = \${t.contrast}
ink = "\${t.ink}"
opaqueWindows = \${t.opaqueWindows}
surface = "\${t.surface}"

[desktop.appearanceDarkChromeTheme.fonts]

[desktop.appearanceDarkChromeTheme.semanticColors]
diffAdded = "\${t.semanticColors.diffAdded}"
diffRemoved = "\${t.semanticColors.diffRemoved}"
skill = "\${t.semanticColors.skill}"
\`;

toml = toml.trim() + '\\n' + themeToml;
fs.writeFileSync(configPath, toml);
EOF

NODE_EXIT=$?
if [ $NODE_EXIT -ne 0 ]; then
  echo -e "${RED}✗ Falha ao escrever no config.toml.${RESET}"
  exit 1
fi

echo -e "\n${GREEN}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ✓ Tema instalado com sucesso!           ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${RESET}\n"
echo -e "${CYAN}→ Abrindo Codex...${RESET}"
open -n -a Codex
