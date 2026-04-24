if status is-login
  /opt/homebrew/bin/brew shellenv | source
  fnm env --corepack-enabled --use-on-cd | source
  source ~/.orbstack/shell/init2.fish 2>/dev/null || :
  source "$HOME/.cargo/env.fish"
  source "$HOME/.vite-plus/env.fish"
end

if status is-interactive
  # initialize starship prompt
  starship init fish | source

  # personal aliases
  alias ..="cd .."
  alias ...="cd ../.."
  alias ....="cd ../../.."

  abbr --add --position command ga git add
  abbr --add --position command gp git push
  abbr --add --position command gl git pull
  abbr --add --position command gco git checkout
  abbr --add --position command gs git status
  abbr --add --position command lg lazygit

  abbr --add --position command p pnpm
  abbr --add --position command pi pnpm install
  abbr --add --position command b bun
  abbr --add --position command bi bun install

  abbr --add --position command c claude
  abbr --add --position command kc kiro-cli chat
end

set --export EDITOR nvim
set --export JAVA_HOME /Library/Java/JavaVirtualMachines/amazon-corretto-21.jdk/Contents/Home
set --export BUN_INSTALL "$HOME/.bun"

fish_add_path $JAVA_HOME
fish_add_path "$BUN_INSTALL/bin"
fish_add_path ~/.local/bin
fish_add_path $HOME/.opencode/bin

# just aws things
set --export --global AWS_PROFILE josef
set --export --global AWS_REGION us-east-1

# eza.rocks
set --export --global EZA_CONFIG_DIR ~/.config/eza

# load environment variables from dotenv files on startup
if status is-interactive
  loadenv --silent; or true
end
