# dotfiles

```bash
# install the basics
brew install \
  fish \       # modern shell - better completion & scripting than bash/zsh
  fnm \        # node version manager - faster alternative to nvm
  fzf \        # fuzzy finder - ctrl+r for history, ctrl+t for files
  gh \         # github CLI - manage PRs, issues from terminal
  jq \         # json swiss army knife - parse/query json in pipelines
  tree \       # visualize directory structure - like ls but hierarchical
  starship \   # minimal fast prompt - works across fish/zsh/bash
  stow \       # symlink farm manager - version control your dotfiles
  luarocks     # lua package manager - needed for some nvim plugins
```

```bash
cd ~/github.com/josefaidt/dotfiles
stow -t ~ .
```

```bash
stow -t ~ nvim zellij fish
```
