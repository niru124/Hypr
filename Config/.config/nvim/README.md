# Neovim config (AstroNvim v5) — portable, self-provisioning

Battery-included Neovim setup for C/C++/Python/Java/Lua/SQL/Arduino development.
Clone it on any machine, run `install.sh`, and everything else (plugins, LSP
servers, debuggers, formatters, Treesitter parsers) installs itself.

## Quick start

```bash
git clone <your-repo-url> ~/.config/nvim
~/.config/nvim/install.sh
nvim
```

Options: `--yes` (non-interactive), `--no-system` (skip OS packages, e.g. you
manage them yourself), `--with-platformio` (also install PlatformIO Core).

Side-by-side with another config: `NVIM_APPNAME=nvim-test ./install.sh`
(the config uses `stdpath("config")`, never hardcoded `~/.config/nvim`).

## What you need beforehand

Only **Neovim ≥ 0.10** and **git** are hard requirements — `install.sh`
installs the rest per OS (pacman / apt / dnf / brew):

| Tool | Why | Fallback if missing |
|---|---|---|
| `node` + `npm` | Some Mason servers, autocmd tooling | Mason servers needing node won't install |
| `python3` + `pip` | `debugpy`, `black`, jedi LSP (via Mason) | Python LSP/debug missing |
| JDK 17+ | `jdtls`, `google-java-format`, spring-initializr | Java support missing |
| `clang` | `clangd`, `clang-format`, `codelldb` target | C/C++ support missing |
| `rg`, `fd` | Telescope file search | Slower built-in search |
| `lazygit`, `ranger`, `glow` | `<leader>lg`, `<leader>E`, `:Glow` | Those shortcuts fail gracefully |
| `trash-cli` | oil.nvim trash delete | Falls back to permanent delete |
| wl-clipboard / xclip / pbcopy | System clipboard | Internal registers only |
| Nerd Font | Icons everywhere | Broken glyphs (script installs CaskaydiaCove) |
| `aider` (via pipx, auto) | `<leader>a*` AI keys | Keys error until installed |
| `pio` (opt-in) | PlatformIO plugin | Plugin stays dormant |

## What auto-provisions on first run

- **Plugins** — lazy.nvim clones everything in `lua/plugins/` + AstroCommunity
  packs (lua, cpp, python, sql, catppuccin, leap, surround, markview).
- **LSP / DAP / formatters** — `mason-tool-installer.nvim` (`lua/plugins/mason.lua`)
  installs: `lua-language-server`, `clangd`, `jedi-language-server`, `jdtls`,
  `arduino-language-server`, `codelldb`, `debugpy`, `java-test`,
  `java-debug-adapter`, `stylua`, `black`, `clang-format`, `sqlfmt`,
  `google-java-format`. Runs automatically on startup; `:MasonToolsInstallSync`
  forces it.
- **Treesitter parsers** — `:TSUpdate` build step + `ensure_installed`
  (`lua`, `vim`, plus `html`/`markdown`/`markdown_inline` for markview).
- **VSCode-style snippets** — `friendly-snippets` + your own in `lua/snippets/`.

## Key maps (leader = ` `)

| Keys | Action |
|---|---|
| `<leader>e` / `<leader>E` | oil explorer / ranger |
| `<leader><leader>` / `<leader><leader>b` | Find files / buffers |
| `<C-/>`, `<C-\>` | Floating terminal; `<leader>th/tv` horizontal/vertical |
| `<S-h>` / `<S-l>` | Prev / next buffer; `<leader>bd` close |
| `gi` | Go to implementation |
| `vaf` / `vif` / `vaa` / `via` … | Treesitter textobjects (function/argument/…) |
| `]m` / `[m` | Next / previous function |
| `<leader>a/` `as` `a+` `a-` … | Aider AI assistant |
| `<leader>lg` | LazyGit |
| `:Format` | Format buffer (conform, LSP fallback) |
| `:Glow` | Render markdown buffer |

## Layout

```
init.lua              bootstrap (lazy.nvim, portable clipboard, file templates)
install.sh            fresh-machine provisioning script
lua/lazy_setup.lua    AstroNvim v5 entry (version = "^5")
lua/community.lua     AstroCommunity packs
lua/polish.lua        runs last; Neovim 0.11+ compat shims for legacy
                      nvim-treesitter queries (safe to keep on v5.3 pins)
lua/plugins/         one file per concern (mason, astrolsp, conform, oil, …)
lua/snippets/        personal LuaSnip snippets
templates/           new-file skeletons (*.cpp/*.sh/*.ino)
```

## Troubleshooting

- `:Lazy restore` — reset all plugins to tested pinned versions.
- `:MasonToolsInstallSync` / `:TSUpdateSync` — re-provision tools/parsers.
- `:checkhealth` — diagnose providers (python/node/clipboard).
- Roll back to the pre-v5 config: `git log` in `~/.config/nvim` and check out
  the `pre-v5 backup` commit (a full copy also lives at
  `~/.config/nvim-backup-v4-20260924` on the original machine).
