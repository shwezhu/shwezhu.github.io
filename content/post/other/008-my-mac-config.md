---
title: My Mac Configuration
date: 2023-11-08 22:50:37
categories:
 - other
tags:
 - other
---

## 1. iTerm2

### 1.1. iTerm2 theme settings

iTerm2 Preferences: `Appearance > General > Theme: Minimal`

iTerm2 Preferences: `Advanced`

![aa](/008-my-mac-config/aa.png)

iTerm2 — Snazzy theme

```shell
$ curl -Ls https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/main/Snazzy.itermcolors > /tmp/Snazzy.itermcolors && open /tmp/Snazzy.itermcolors
```

Configure iTerm2 color theme: iTerm2 Preferences:` Profiles > Colors > Color Presets: Snazzy`

### 1.2. Install Oh My Zsh and zplug

```shell
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# zplug
brew install zplug
```

`.zshrc` file:

```
# ~.zshrc
export ZSH=~/.oh-my-zsh
# disable oh-my-zsh themes for pure prompt
ZSH_THEME=""
source $ZSH/oh-my-zsh.sh
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
zplug load
# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
```

## 1.3. syntax highlighting & auto suggestions

```shell
zplug "zdharma/fast-syntax-highlighting", as:plugin, defer:2

zplug "zsh-users/zsh-autosuggestions", as:plugin, defer:2
```

Then reload your iTerm2, you will see the change after download.

Reference: [Beautify your iTerm2 and prompt 💋 | by Steven Chim | airfrance-klm | Medium](https://medium.com/airfrance-klm/beautify-your-iterm2-and-prompt-40f148761a49)

## 2. Clean 

[PrettyClean](https://www.prettyclean.cc/zh)

[mac-cleanup-sh](https://github.com/mac-cleanup/mac-cleanup-sh) 

## 3. Nvim

### install

```shell
brew install neovim
echo "alias vim='nvim'" >> ~/.zshrc
git clone -b v2.0 https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
# for live grep search
brew install ripgrep
```

### font

Change font of iTerm2 otherwise you will see some weird characters in nvim.

```shell
❯ brew tap homebrew/cask-fonts
❯ brew install --cask font-jetbrains-mono-nerd-font
```

Then set the font in iTerm2 Preferences: `Profiles > Text > Font: jetbrains-mono-nerd`

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/04/91da077a280e806eb70e5fdc26b4a8ed.jpg)

Learn more: [How to Install Nerd Fonts on mac](https://www.geekbits.io/how-to-install-nerd-fonts-on-mac/)

### theme

Chnage the theme of nvim, enter nvim and type `space` + `t` + `h`, choose *onenord* theme.

### Highlight

```shell
:TSInstall markdown
:TSInstall markdown_inline
:setlocal spell spelllang=en_us, cjk spellcapcheck=""
```

### Plugins

Edit `~/.config/nvim/lua/custom/chadrc.lua`:

```lua
local M = {}

M.ui = { theme = 'onenord' }

M.plugins = 'custom.plugins'

return M
```

Add new file `~/.config/nvim/lua/custom/plugins.lua`:

```lua
local plugins = {
  {
    "Pocco81/auto-save.nvim",
    lazy = false,
	  config = function()
		      require("auto-save").setup {
			    -- your config goes here
			    -- or just leave it empty :)
		      }
	  end,
  }
}

return plugins
```

### Shortcuts

https://docs.rockylinux.org/books/nvchad/nvchad_ui/nvchad_ui/

### Final

`custom/chadrc.lua`:
```lua
---@type ChadrcConfig
local M = {}

M.ui = { theme = 'onenord' }

M.plugins = 'custom.plugins'

return M
```

`custom/plugins.lua`:
```lua
local plugins = {
  {
    "Pocco81/auto-save.nvim",
    lazy = false,
    config = function()
        require("auto-save").setup {
			    -- your config goes here
			    -- or just leave it empty :)
		    }
	  end,
  },
  {
    "github/copilot.vim",
    lazy = false,
  },
  {
    'MeanderingProgrammer/markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = 'markdown',
    config = function()
        require('render-markdown').setup({})
    end,
  },
}

return plugins
```
