#!/usr/bin/env bash
# =============================================================================
# Codex Native Theme Installer - SovietWave
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuração para instalação remota:
# Se o usuário baixar apenas este script, ele tentará baixar os temas deste URL.
# Altere para o link do seu repositório no GitHub (Raw).
GITHUB_BASE_URL="https://raw.githubusercontent.com/victorcrbt/sovietwave/main/codex"
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_BIN="/Applications/Codex.app/Contents/MacOS/Codex"
PORT=19283

RED='\033[0;31m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "\n${RED}╔══════════════════════════════════════════╗${RESET}"
echo -e "${RED}║${CYAN}   🌊  SOVIETWAVE — Codex Theme Installer ${RED}║${RESET}"
echo -e "${RED}╚══════════════════════════════════════════╝${RESET}\n"

# 1. Escolha da variante
echo -e "Qual variante você deseja instalar?"
echo -e "  1) SovietWave (Base)"
echo -e "  2) SovietWave - Zhukov"
# Adicionado < /dev/tty para suportar execução via 'curl | bash'
read -r -p "Escolha [1/2]: " VARIANT_CHOICE < /dev/tty

if [ "$VARIANT_CHOICE" == "2" ]; then
  THEME_FILENAME="sovietwave-zhukov.json"
else
  THEME_FILENAME="sovietwave.json"
fi

THEME_FILE="$SCRIPT_DIR/$THEME_FILENAME"

# 2. Obter o tema (local ou remoto)
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

# Extrair JSON (removendo o prefixo "codex-theme-v1:" se existir)
if [[ "$THEME_CONTENT" == codex-theme-v1:* ]]; then
  THEME_JSON="${THEME_CONTENT#codex-theme-v1:}"
else
  THEME_JSON="$THEME_CONTENT"
fi

# 3. Localizar o Codex
if [ ! -x "$CODEX_BIN" ]; then
  echo -e "${YELLOW}⚠ Codex não encontrado no local padrão ($CODEX_BIN).${RESET}"
  echo -e "Dica: No Mac, normalmente ele fica em /Applications/Codex.app/Contents/MacOS/Codex"
  echo -e "No Linux/Windows WSL, o caminho pode variar."
  read -r -p "Gostaria de informar o caminho do binário manualmente? (S/N) " RESP < /dev/tty
  if [[ "$RESP" =~ ^[Ss]$ ]]; then
    read -r -p "Informe o caminho: " CODEX_BIN < /dev/tty
    CODEX_BIN="${CODEX_BIN/#\~/$HOME}"
    if [ ! -x "$CODEX_BIN" ]; then
      echo -e "${RED}✗ Binário inválido. Cancelando.${RESET}"
      exit 1
    fi
  else
    echo -e "${RED}✗ Instalação cancelada.${RESET}"
    exit 1
  fi
fi

if ! command -v node &>/dev/null; then
  echo -e "${RED}✗ Node.js não encontrado. Necessário para injetar o tema.${RESET}"
  exit 1
fi

# 4. Injeção (O Codex não usa pasta de temas, guarda direto no banco de dados interno)
if pgrep -x Codex &>/dev/null; then
  echo -e "${CYAN}→ Fechando o Codex...${RESET}"
  pkill -x Codex || true
  sleep 2
fi

echo -e "${CYAN}→ Iniciando Codex no modo debug (porta $PORT)...${RESET}"
"$CODEX_BIN" --remote-debugging-port="$PORT" --remote-debugging-address=127.0.0.1 \
  --no-first-run > /dev/null 2>&1 &
CODEX_PID=$!

trap "kill $CODEX_PID 2>/dev/null || true" EXIT

echo -e "${CYAN}→ Aguardando inicialização...${RESET}"
for i in {1..25}; do
  if curl -sf "http://127.0.0.1:$PORT/json/list" > /dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -sf "http://127.0.0.1:$PORT/json/list" > /dev/null 2>&1; then
  echo -e "${RED}✗ Timeout ao conectar ao Codex.${RESET}"
  exit 1
fi

echo -e "${CYAN}→ Injetando tema nativamente...${RESET}"

node - <<EOF
const http = require('node:http');
const PORT = $PORT;
const THEME_KEY = 'codex-theme-v1';
const themeJsonString = \`$THEME_JSON\`;

async function getTargets() {
  return new Promise((resolve, reject) => {
    http.get(\`http://127.0.0.1:\${PORT}/json/list\`, (res) => {
      let data = '';
      res.on('data', d => data += d);
      res.on('end', () => resolve(JSON.parse(data)));
    }).on('error', reject);
  });
}

async function cdpEvaluate(wsUrl, expression) {
  const ws = new WebSocket(wsUrl);
  await new Promise((res, rej) => {
    ws.addEventListener('open', res);
    ws.addEventListener('error', rej);
  });

  const result = await new Promise((res, rej) => {
    ws.addEventListener('message', ({ data }) => {
      const msg = JSON.parse(data);
      if (msg.id === 1) res(msg);
    });
    ws.send(JSON.stringify({
      id: 1,
      method: 'Runtime.evaluate',
      params: { expression, returnByValue: true }
    }));
    setTimeout(() => rej(new Error('CDP timeout')), 8000);
  });

  ws.close();
  return result;
}

(async () => {
  try {
    const targets = await getTargets();
    const target = targets.find(t => t.type === 'page' && t.url?.startsWith('app://')) ||
                   targets.find(t => t.type === 'page') ||
                   targets[0];

    if (!target?.webSocketDebuggerUrl) throw new Error('Nenhum target CDP');

    const expression = \`localStorage.setItem('\${THEME_KEY}', JSON.stringify(\${themeJsonString})); 'ok'\`;
    const result = await cdpEvaluate(target.webSocketDebuggerUrl, expression);

    if (result.result?.exceptionDetails) throw new Error(result.result.exceptionDetails.text);
  } catch (err) {
    console.error('ERRO:', err.message);
    process.exit(1);
  }
})();
EOF

NODE_EXIT=$?
if [ $NODE_EXIT -ne 0 ]; then
  echo -e "${RED}✗ Falha na injeção do tema.${RESET}"
  exit 1
fi

trap - EXIT
kill "$CODEX_PID" 2>/dev/null || true
sleep 1

echo -e "\n${GREEN}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ✓ Tema instalado com sucesso!           ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${RESET}\n"
echo -e "  Abrindo o Codex...\n"
open -a Codex
