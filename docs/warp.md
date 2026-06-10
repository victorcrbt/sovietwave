# Instalação: Warp Terminal

O Warp Terminal possui um suporte nativo simples e excelente para temas customizados através de arquivos YAML. 

O tema SovietWave ajusta todas as 16 cores ANSI padrão, background, foreground e a cor de destaque (accent) da interface do Warp, sem a necessidade de plugins.

## 🚀 Método 1: Instalação Automatizada por Script (macOS / Linux)

Para instalar instantaneamente sem precisar baixar e mover arquivos manualmente, use nosso instalador remoto.

1. Abra o seu Warp Terminal.
2. Cole e execute o comando abaixo:
   ```bash
   curl -sL https://raw.githubusercontent.com/victorcrbt/sovietwave/main/terminals/warp/install.sh | bash
   ```
3. O script perguntará qual variante você quer (`1` para Base, `2` para Zhukov).
4. O script criará a pasta `~/.warp/themes` (se não existir) e copiará os arquivos.
5. Em seguida, pressione `Cmd + P` no Warp, digite **"Open theme picker"** e pesquise por **SovietWave**. Selecione-o e pronto!

## ✋ Método 2: Instalação Manual

Se preferir fazer você mesmo:

1. Baixe o arquivo `sovietwave.yaml` ou `sovietwave-zhukov.yaml` da pasta `terminals/warp/` deste repositório.
2. Mova o arquivo baixado para a pasta de temas do Warp, localizada no seu diretório de usuário:
   ```bash
   # Exemplo via terminal:
   mkdir -p ~/.warp/themes/
   cp ~/Downloads/sovietwave*.yaml ~/.warp/themes/
   ```
3. Abra o Warp, acesse **Settings -> Appearance -> Themes**.
4. Procure por **SovietWave** na lista e clique para ativar.
