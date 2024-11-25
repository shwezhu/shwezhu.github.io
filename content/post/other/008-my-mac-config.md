---
title: My Mac Configuration
date: 2023-11-08 22:50:37
categories:
 - other
tags:
 - other
---

## Softwares

[PrettyClean](https://www.prettyclean.cc/zh)

[mac-cleanup-sh](https://github.com/mac-cleanup/mac-cleanup-sh) 

Snipaste ScreenShoot

Raycast AI (Youtube Downloader, Twitter Downloader, Clipboard, Quick Emoij)

Arc (uBlock Origin Lite)

## Config

**Transfer Arc Browser**

This won't transfer the passwords, and your profiles, but your shortcuts will be transferred. Arc is a shit!

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/d8ebc97b5bb6c427f6b2ce9cca72947b.jpg)

**Spotlight Settings**

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/334f19d638ada2230c0981846da8fd4d.jpg)

**Shortcuts:**

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/23345ee633c3dd55af79b24fd1bf7bec.jpg)

## 3. iTerm2

1. Setting themes: go to settings: `Appearance > General > Theme: Minimal`

2. Remove annoying outlines on tabs, go to settings: `Advanced`

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/060dccf96c2b61a6e4ceaf7ce3650931.png)

3. Setting color to Snazzy:

```shell
$ curl -Ls https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/main/Snazzy.itermcolors > /tmp/Snazzy.itermcolors && open /tmp/Snazzy.itermcolors
```

Then go to settings:` Profiles > Colors > Color Presets: Snazzy`

4. Install Oh My Zsh

```shell
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

5. syntax highlighting & auto suggestions

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

Edit `.zshrc` file, find `plugins=(git)`, append two plugins:

```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

## 4. Neovim

```shell
brew install neovim
echo "alias vim='nvim'" >> ~/.zshrc
echo "alias vi='nvim'" >> ~/.zshrc

# Install NvChad, it's a starter branch, only clone the latest commit
git clone https://github.com/NvChad/starter ~/.config/nvim --depth 1 && nvim
```

### Font

Change font of iTerm2 otherwise you will see some weird characters in nvim.

```shell
❯ brew tap homebrew/cask-fonts
❯ brew install --cask font-jetbrains-mono-nerd-font
```

Then set the font in iTerm2 Preferences: `Profiles > Text > Font: jetbrains-mono-nerd`

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/04/91da077a280e806eb70e5fdc26b4a8ed.jpg)

### Theme

Chnage the theme of nvim, enter nvim and type `space` + `t` + `h`, choose ***onenord*** theme.

### Highlight & spell checking

In vim command, execute the following command(install once, no need to do this every time): 

```shell
:TSInstall markdown
:TSInstall markdown_inline
```

Go to `.config/nvim/init.lua`:

```lua
-- Spelling Checking
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true -- current buffer only
    vim.opt_local.spelllang = "en_us,cjk" -- english, chinese
    vim.opt_local.spellcapcheck = ""
  end
})
```

### Plugins AutoSave

Edit `~/.config/nvim/lua/custom/chadrc.lua`:

```lua
local M = {}

M.ui = { theme = 'onenord' }

M.plugins = 'custom.plugins'

return M
```

Add new file `~/.config/nvim/lua/custom/plugins.lua`:

```lua
-- 自定义插件列表
local plugins = {
  {
    -- 自动保存插件
    "Pocco81/auto-save.nvim",
    -- lazy = false 表示立即加载插件,而不是懒加载
    lazy = false,
    -- 插件配置函数
    config = function()
        -- 加载并设置 auto-save 插件
        require("auto-save").setup {
            -- 这里可以添加自定义配置
            -- 或者保持空配置使用默认设置
        }
    end,
  },
}
return plugins
```

https://docs.rockylinux.org/books/nvchad/nvchad_ui/nvchad_ui/



