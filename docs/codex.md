# Instalação: Codex Desktop

Devido à arquitetura fechada do aplicativo Codex Desktop, a instalação de temas envolve injetar a configuração da interface customizada diretamente no seu painel de configurações.

Preparamos duas vias fáceis de instalação: um script automatizado ou a importação clássica.

## 🚀 Método 1: Instalação Automatizada por Script (Linux / macOS)

Criamos um instalador que configura tudo para você através de um script no terminal.

1. Abra o seu Terminal.
2. Cole e execute o seguinte comando:
   ```bash
   curl -sL https://raw.githubusercontent.com/victorcrbt/sovietwave/main/codex/install.sh | bash
   ```
3. O script irá perguntar qual variante você deseja instalar (`1` para a Base ou `2` para Zhukov).
4. Em seguida, ele oferecerá duas opções de ação:
   - **(Opção 1) Injeção Direta:** O script modifica o arquivo `config.toml` do Codex por você. Você verá as modificações na próxima vez que o Codex abrir.
   - **(Opção 2) Copiar para o Clipboard:** O script apenas carrega o payload do tema (sem realizar nenhuma injeção de arquivos locais) e envia para a sua área de transferência, para que você aplique pela Interface Visual do Codex (veja o método 2 abaixo).

## ✋ Método 2: Importação Manual (Pela UI do Codex)

Caso prefira não usar comandos de terminal ou esteja utilizando Windows, você pode aplicar a configuração diretamente pelo próprio menu de configurações visuais do Codex.

1. Abra o arquivo [sovietwave.json](../codex/sovietwave.json) (ou `sovietwave-zhukov.json`) deste repositório e **copie todo o texto contido nele**. (A string começará com `codex-theme-v1:{...}`).
2. Abra o aplicativo Codex Desktop.
3. Clique no ícone de engrenagem (**Settings/Configurações**) no painel inferior esquerdo.
4. Navegue até o menu **Appearance** (Aparência).
5. Certifique-se de estar usando o tema **Escuro (Dark)**.
6. Localize a seção *Tema Escuro* e clique no botão **Import** (ao lado do botão de copiar o tema).
7. Cole o conteúdo no modal que aparecer e confirme. A interface vai recarregar instantaneamente com as cores do painel SovietWave!

---

> **⚠️ Atenção Crítica sobre a Coloração de Código (Syntax Highlighting)**
> 
> A customização de temas para o Codex altera primariamente a **Interface de Usuário** (os botões, a barra lateral, fundos, abas). O aplicativo **não suporta** sobrescrever a coloração interna da sintaxe de código (os `tokens` e palavras-chave) via JSON de importação, pois estas cores são fixas e distribuídas unicamente embutidas no binário do aplicativo.
> 
> Por definição, usamos o código visual "Codex" como âncora. Se você quer que as palavras-chave do código também entrem num tom que acompanhe as paletas avermelhadas (em vez do azul e roxo padrão), basta abrir o menu `Settings -> Appearance` e alterar a opção **Tema de código** (o menu dropdown ao lado do botão de importar) e escolher outros nativos, como *Gruvbox*, *One Dark Pro* ou *Material*.
