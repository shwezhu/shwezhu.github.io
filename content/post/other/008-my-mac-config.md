---
title: My Mac Configuration
date: 2023-11-08 22:50:37
categories:
 - other
tags:
 - other
typora-root-url: ../../../static
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
