if status is-interactive
  # initialize starship prompt
  starship init fish | source

  # load fnm
  fnm env --corepack-enabled --use-on-cd | source

  # personal aliases
  alias p="pnpm"
  alias ..="cd .."
  alias ...="cd ../.."
  alias ....="cd ../../.."

  abbr --add --position command gp git push
  abbr --add --position command gco git checkout
  abbr --add --position command gs git status
  abbr --add --position command lg lazygit
end

set --export JAVA_HOME /Library/Java/JavaVirtualMachines/amazon-corretto-21.jdk/Contents/Home
set --export BUN_INSTALL "$HOME/.bun"

/opt/homebrew/bin/brew shellenv | source
fish_add_path $JAVA_HOME
fish_add_path "$BUN_INSTALL/bin"
fish_add_path ~/.local/bin

# just aws things
set --export --global AWS_PROFILE josef
set --export --global AWS_REGION us-east-1

# eza.rocks
set --export --global EZA_CONFIG_DIR ~/.config/eza

# load environment variables from dotenv files on startup
loadenv --silent; or true

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# load rust
source "$HOME/.cargo/env.fish"

