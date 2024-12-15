---
title: My Mac Configuration
date: 2023-11-08 22:50:37
categories:
 - other
tags:
 - other
---

```bash
# 查看什么影响休眠
$ pmset -g log | grep PreventUserIdleSystemSleep

# 睡眠 电脑总是发烫, sudo pmset -a tcpkeepalive 1 取消设置
$ sudo pmset -a tcpkeepalive 0
Warning: This option disables TCP Keep Alive mechanism when sytem is sleeping. This will result in some critical features like 'Find My Mac' not to function properly

# 禁止 Mac 在睡眠时执行一些后台任务：检查邮件更新 同步 iCloud
# https://support.apple.com/en-ca/guide/mac-help/mh40774/mac
$ sudo pmset -a powernap 0

# 查看SSD写入量
$ smartctl -a disk0
```

## Softwares

[AppCleaner](https://freemacsoft.net/appcleaner/)

Snipaste ScreenShoot

Raycast AI (Youtube Downloader, Twitter Downloader, Clipboard, Quick Emoij)

Arc (uBlock Origin Lite, [bpc-clone/bypass-paywalls-chrome-clean](https://github.com/bpc-clone/bypass-paywalls-chrome-clean?tab=readme-ov-file#installation),  Openai Translator)

## Config
**Transfer Arc Browser**

This won't transfer the passwords, and your profiles, but your shortcuts will be transferred. Arc is a shit!

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/d8ebc97b5bb6c427f6b2ce9cca72947b.jpg)

**Spotlight Settings**

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/334f19d638ada2230c0981846da8fd4d.jpg)

**Shortcuts:**

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/23345ee633c3dd55af79b24fd1bf7bec.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/a32f686f24dc8c72798dd3b6ff436f96.jpg)

https://support.apple.com/en-in/102650

## 3. iTerm2

1. Setting themes: go to settings: `Appearance > General > Theme: Minimal`

2. Remove annoying outlines on tabs, go to settings: `Advanced`

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/060dccf96c2b61a6e4ceaf7ce3650931.png)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/12/763ffe39b9e497a940503faa215d6365.png)

3. Setting color to Github:

```shell
$ curl -Ls https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Github.itermcolors -o /tmp/Github.itermcolors && open /tmp/Github.itermcolors
```

Then go to settings:` Profiles > Colors > Color Presets: GitHub`

4. Install Oh My Zsh

```shell
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

5. auto suggestions

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

Edit `.zshrc` file, find `plugins=(git)`, append two plugins:

```bash
plugins=(git zsh-autosuggestions)
```

6. Final Version `.zshrc`:

```bash
# ZSH 是个(全局)变量定义了 oh-my-zsh 的安装路径
# 使用 export 是因为其他子进程(如插件脚本)也需要知道这个位置
# 如果去掉 export，其他脚本可能访问不到这个变量
export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME 定义主题，这是个普通变量，不需要 export
# 因为只有 oh-my-zsh.sh 主脚本需要读取它
ZSH_THEME="robbyrussell"

# plugins 定义需要加载哪些插件，也是个普通变量
# 只在 source oh-my-zsh.sh 时被读取一次
plugins=(
    git 
    zsh-autosuggestions
)

# 执行 oh-my-zsh 的主脚本，它会：
# 1. 读取上面的配置变量
# 2. 加载指定的主题
# 3. 加载所有列出的插件
source $ZSH/oh-my-zsh.sh% 
```

## 3. Nvim
```shell
brew install neovim
echo "alias vim='nvim'" >> ~/.zshrc
echo "alias vi='nvim'" >> ~/.zshrc

# Install NvChad
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
```

到 `~/.config/nvim/lua/plugins/init.lua`, 删除原内容, 直接拷贝, 

```lua
return {
 {
   -- 代码格式化插件 - 可以自动格式化各种语言的代码
   -- 可以配置使用不同的格式化工具(例如 prettier, stylua, black 等)
   "stevearc/conform.nvim",
   -- event = 'BufWritePre', -- 取消注释这行会在保存时自动格式化
   opts = require "configs.conform",
 },
 {
   -- LSP(Language Server Protocol)配置插件
   -- 提供代码补全、跳转到定义、查找引用、错误提示等功能
   -- 支持多种编程语言，每种语言需要安装对应的 language server
   "neovim/nvim-lspconfig",
   config = function()
     require "configs.lspconfig"
   end,
 },
 {
   -- GitHub Copilot 插件 - AI 代码助手
   -- 可以根据上下文自动生成代码建议
   -- 需要 GitHub 账号并订阅 Copilot 服务
   "github/copilot.vim",
   lazy = false,
 },
 {
   -- 自动保存
   "okuuva/auto-save.nvim",
   version = '^1.0.0',
   cmd = "ASToggle", -- optional for lazy loading on command
   event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
   opts = {
     -- your config goes here
     -- or just leave it empty :)
   },
   lazy = false,
 },
}
```

启动 neovim, 然后输入 `: Copilot setup`

### 3.1. **Font**

Change font of iTerm2 otherwise you will see some weird characters in nvim.

```shell
# https://formulae.brew.sh/cask-font/
❯ brew install --cask font-jetbrains-mono-nerd-font
```

Then set the font in iTerm2 Preferences: `Profiles > Text > Font: jetbrains-mono-nerd`, 注意选择 nerd font, 不要选择 jetbrains-mono-font: 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/04/91da077a280e806eb70e5fdc26b4a8ed.jpg)

### 3.2. **Theme**

Chnage the theme of nvim, enter nvim and type `space` + `t` + `h`, choose ***onenord*** or **github** theme.

### 3.3. **设置 cursor** 

Append to `.config/nvim/init.lua`:

```lua
vim.opt.guicursor = "n-v-c-i:hor20"
```

### 3.4. 快捷键

显示文件树: 空格 + e

全选: ggVG

复制: 选择内容后 按 y

cut: 选择内容后 按 x
