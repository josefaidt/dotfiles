---
name: dotfiles
description: Fix a neovim or dotfiles configuration issue. Adds a task to ~/github.com/josefaidt/dotfiles/notes.md and implements the fix. Use when you notice a neovim issue and want to fix it in your dotfiles.
argument-hint: [describe the issue]
---

Fix the following dotfiles/neovim issue: $ARGUMENTS

The dotfiles repository lives at ~/github.com/josefaidt/dotfiles.

1. Read ~/github.com/josefaidt/dotfiles/notes.md and add `- [ ] $ARGUMENTS` to the `## Todo` section
2. Explore the relevant configuration — neovim config is in ~/github.com/josefaidt/dotfiles/.config/nvim/
3. Implement the fix
4. Mark the notes.md item as `[x]` once complete
