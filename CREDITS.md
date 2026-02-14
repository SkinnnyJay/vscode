# Credits

Sources and attribution for claims and guidance in the Pointer IDE documentation and README.

---

## Upstream: Code - OSS and VS Code

- **Code - OSS vs VS Code distribution** — Differences between the repository and the Visual Studio Code product (proprietary assets, Marketplace integration).  
  [Differences between the repository and Visual Studio Code](https://github.com/microsoft/vscode/wiki/Differences-between-the-repository-and-Visual-Studio-Code) (GitHub)

- **Build and run** — Upstream install, watch, and launch commands (`npm install`, `npm run watch`, `./scripts/code.sh`, `.\scripts\code.bat`); Marketplace not available from open-source builds; VSIX side-loading.  
  [How to Contribute](https://github.com/microsoft/vscode/wiki/How-to-Contribute) (GitHub)

- **Visual Studio Marketplace** — Terms of use; offerings intended for “In-Scope Products and Services” only.  
  [Visual Studio Marketplace Terms of Use](https://cdn.vsassets.io/v/M190_20210811.1/_content/Microsoft-Visual-Studio-Marketplace-Terms-of-Use.pdf) (Microsoft)

---

## VS Code extensibility and AI

- **Chat Participant API** — How chat participants integrate via extension APIs.  
  [VS Code AI Chat](https://code.visualstudio.com/api/extension-guides/ai/chat) (Visual Studio Code)

- **Language model / inline suggestions** — Local models not supported for built-in inline path; `InlineCompletionItemProvider` for custom providers.  
  [Language models customization](https://code.visualstudio.com/docs/copilot/customization/language-models) (Visual Studio Code)

---

## Provider CLIs and backends

- **Codex** — IDE extension shares agent/config with Codex CLI; installation (`npm i -g @openai/codex`, `brew install --cask codex`); local terminal agent.  
  [Codex IDE features](https://developers.openai.com/codex/ide/features/) (OpenAI)  
  [Codex CLI](https://github.com/openai/codex) (GitHub)

- **Claude Code** — Overview and installation.  
  [claude-code](https://github.com/anthropics/claude-code) (GitHub)

- **OpenCode** — CLI with TUI by default; programmatic command mode (`opencode run`).  
  [OpenCode CLI](https://opencode.ai/docs/cli/) (opencode.ai)

---

## Protocols

- **Agent Client Protocol (ACP)** — JSON-RPC model for agents and clients.  
  [ACP overview](https://agentclientprotocol.com/protocol/overview) (agentclientprotocol.com)

- **Model Context Protocol (MCP)** — Open protocol for connecting models to tools and data sources.  
  [MCP](https://modelcontextprotocol.io/) (modelcontextprotocol.io)
