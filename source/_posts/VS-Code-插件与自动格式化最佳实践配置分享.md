---
title: VS Code 插件与自动格式化最佳实践配置分享
date: 2025-06-09 20:30:00
categories:
  - 编程环境
tags:
  - VSCode
  - 插件推荐
  - 自动格式化
  - 开发效率
description: 个人常用 VS Code 插件清单、自动格式化配置，以及跨语言开发的效率优化心得，适合各类后端、前端与云原生开发者参考。
---

# VS Code 插件与自动格式化最佳实践配置分享

VS Code 是我日常开发的主力编辑器。无论是脚本、后端、前端还是基础设施即代码，我都力求做到**编辑器即开即用、保存即格式化、团队风格统一**。本文整理了我的 VS Code 插件清单、详细的格式化配置，以及一些实践经验，希望对大家有所帮助。

## 插件清单（`code --list-extensions`）

我的插件覆盖了前后端、运维、数据和基础设施开发的多种场景，精选了每类的代表性扩展：

```sh
code --install-extension aaron-bond.better-comments                # 注释增强
code --install-extension ahmadalli.vscode-nginx-conf               # Nginx 配置
code --install-extension christian-kohler.path-intellisense        # 路径自动补全
code --install-extension davidanson.vscode-markdownlint            # Markdown 规范
code --install-extension eamodio.gitlens                           # Git 超强增强
code --install-extension editorconfig.editorconfig                 # 多人协作风格一致
code --install-extension esbenp.prettier-vscode                    # 代码格式化
code --install-extension foxundermoon.shell-format                 # Shell 脚本格式化
code --install-extension golang.go                                 # Go 语言支持
code --install-extension hashicorp.terraform                       # Terraform 支持
code --install-extension johnnymorganz.stylua                      # Lua 格式化
code --install-extension lkrms.inifmt                              # ini/ignore 配置格式化
code --install-extension mechatroner.rainbow-csv                   # CSV 可视化
code --install-extension ms-ceintl.vscode-language-pack-zh-hans    # 简体中文语言包
code --install-extension ms-python.black-formatter                 # Python 格式化
code --install-extension ms-python.debugpy                         # Python 调试
code --install-extension ms-python.python                          # Python 支持
code --install-extension ms-python.vscode-pylance                  # Python 智能提示
code --install-extension pkief.material-icon-theme                 # 文件图标主题
code --install-extension redhat.vscode-xml                         # XML 支持
code --install-extension redhat.vscode-yaml                        # YAML 支持
code --install-extension rust-lang.rust-analyzer                   # Rust 智能提示
code --install-extension voidei.vscode-vimrc                       # vimrc 语法高亮
code --install-extension vue.volar                                 # Vue 3 支持
code --install-extension yoieh.add-gitignore-vscode                # .gitignore 管理
code --install-extension yzhang.markdown-all-in-one                # Markdown 增强
```


## 自动格式化与编辑体验配置

针对常用语言和格式，全部实现了保存自动格式化，团队协作下再也不用担心风格不统一。以下配置可直接放到 `.vscode/settings.json` 或全局 `settings.json`：

```json
{
  "[ignore]": { "editor.defaultFormatter": "lkrms.inifmt" },
  "[ini]": { "editor.defaultFormatter": "lkrms.inifmt" },
  "[lua]": { "editor.defaultFormatter": "JohnnyMorganz.stylua" },
  "[luau]": { "editor.defaultFormatter": "JohnnyMorganz.stylua" },
  "[markdown]": {
    "editor.defaultFormatter": "yzhang.markdown-all-in-one",
    "editor.formatOnSave": true,
    "editor.quickSuggestions": { "comments": "off", "other": "off", "strings": "off" },
    "editor.wordWrap": "on"
  },
  "[nginx]": { "editor.defaultFormatter": "ahmadalli.vscode-nginx-conf" },
  "[shellscript]": { "editor.defaultFormatter": "foxundermoon.shell-format" },
  "[yaml]": {
    "editor.defaultFormatter": "redhat.vscode-yaml",
    "editor.detectIndentation": false,
    "editor.formatOnSave": true,
    "editor.insertSpaces": true,
    "editor.tabSize": 2
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.tabSize": 2
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.tabSize": 2
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.tabSize": 2
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.tabSize": 2
  },
  "[html]": { "editor.defaultFormatter": "esbenp.prettier-vscode", "editor.formatOnSave": true },
  "[css]": { "editor.defaultFormatter": "esbenp.prettier-vscode", "editor.formatOnSave": true },
  "[scss]": { "editor.defaultFormatter": "esbenp.prettier-vscode", "editor.formatOnSave": true },
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.formatOnSave": true,
    "editor.formatOnType": true
  },
  "[go]": { "editor.defaultFormatter": "golang.go", "editor.formatOnSave": true },
  "[rust]": { "editor.defaultFormatter": "rust-lang.rust-analyzer", "editor.formatOnSave": true },
  "[terraform]": { "editor.defaultFormatter": "hashicorp.terraform" },
  "[vimrc]": { "editor.defaultFormatter": null },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.fontFamily": "'MesloLGS NF', 'Symbols Nerd Font Mono', Menlo, Monaco, 'Courier New', monospace",
  "editor.fontSize": 14,
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "editor.unicodeHighlight.allowedLocales": { "zh-hans": true },
  "editor.unicodeHighlight.includeStrings": false,
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": true,
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.minimap.enabled": false,
  "editor.rulers": [120],
  "files.autoSave": "onFocusChange",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.associations": {
    "*.json": "json",
    "*.log": "log",
    "*.md": "markdown",
    "*.toml": "toml",
    "*.yaml": "yaml",
    ".gitignore": "ignore",
    "gitignore": "ignore",
    "*.vimrc": "vimrc"
  },
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "gitlens.hovers.enabled": true,
  "gitlens.codeLens.enabled": true,
  "rainbow_csv.autodetect_separators": [",", "\t", ";", "|"],
  "rainbow_csv.enable_context_menu_head": true,
  "problems.autoReveal": false,
  "debug.internalConsoleOptions": "neverOpen",
  "security.workspace.trust.untrustedFiles": "open",
  "typescript.tsserver.nodePath": "/opt/homebrew/opt/node@22/bin/node",
  "workbench.iconTheme": "material-icon-theme",
  "workbench.startupEditor": "none",
  "prettier.singleQuote": true,
  "prettier.tabWidth": 2,
  "prettier.useTabs": false,
  "prettier.printWidth": 120,
  "editorconfig.generateAuto": true,
  "yaml.format.enable": true,
  "yaml.hover": true,
  "yaml.keyOrdering": false,
  "yaml.maxItemsComputed": 3000,
  "yaml.schemas": {
    "https://json.schemastore.org/github-workflow.json": "/*.github/workflows/*"
  },
  "yaml.schemaStore.enable": true,
  "yaml.style.flowMapping": "allow",
  "yaml.style.flowSequence": "allow",
  "yaml.validate": true,
  "yaml.yamlVersion": "1.2",
  "stylua.configPath": "/opt/homebrew/bin/stylua",
  "python.analysis.importFormat": "relative",
  "go.useLanguageServer": true,
  "go.formatTool": "gofmt",
  "rust-analyzer.cargo.buildScripts.enable": true,
  "rust-analyzer.check.command": "clippy",
  "terraform.languageServer.enable": true,
  "terraform.languageServer.path": "/opt/homebrew/bin/terraform-ls",
  "terraform.codelens.referenceCount": true,
  "vue.codeActions.enabled": true,
  "vue.complete.casing.tags": "autoKebab",
  "shellformat.path": "/opt/homebrew/bin/shfmt",
  "rainbow_csv.enable_auto_csv_lint": true,
  "markdownlint.config": { "default": false, "MD013": false }
}
```

> 如需配合团队协作，建议在项目根目录配合 `.editorconfig` 保证多端一致。
## 依赖第三方应用安装（macOS）

```sh
brew install stylua
brew install black
brew install shfmt
brew install terraform-ls
```


## 经验总结与实践建议

1. **插件不在多而在精**，每个类型只选最优解决方案。
2. **保存自动格式化**是团队协作的底线，保证代码风格统一不内耗。
3. **配置路径优先用 Homebrew 方式**，兼容性最佳，也方便自动升级。
4. **多语言项目首选 VS Code**，无论是 Python、Go、Rust 还是 Terraform，官方插件都已非常完善。
5. **.gitignore 管理插件**极大提升多语言项目的体验，强烈建议配合使用。

## 结语

开发工具不是越多越好，而是要“刚刚好”。插件和配置选得准，日常开发才能省心高效。希望这份经验对你有帮助，有更好的插件和配置也欢迎交流讨论！

---

如果你有其它 VS Code 配置和插件推荐，欢迎评论区留言一起讨论交流！
