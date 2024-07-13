if status is-interactive
  # Commands to run in interactive sessions can go here
end

if status --is-login
  fish_add_path ~/.emacs.d/bin
  fish_add_path ~/bin
  fish_add_path $HOME/.cargo/bin
  fish_add_path ~/.local/bin
end

# test -e (pwd)/.nvmrc && fnm use

alias cat="bat"
alias nvm="fnm"
alias vl="vercel"
alias vn="vite-node"
alias gp="git push"
alias cdl="cd ~/Downloads"
alias t="tmux"
alias e="emacs"
alias gs="git status"
alias yawn="pnpm"
alias p="pnpm"
alias pi="pnpm install"
alias c="code ."
alias lgrep="ls -al | grep"
alias px="pnpm -s dlx"
alias mk="mkdir -p $1 && cd $1"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

set fish_color_autosuggestion 555 brblack
set fish_color_cancel -r
set fish_color_command --bold
set fish_color_comment red
set fish_color_cwd green
set fish_color_cwd_root red
set fish_color_end brmagenta
set fish_color_error brred
set fish_color_escape bryellow --bold
set fish_color_history_current --bold
set fish_color_host normal
set fish_color_host_remote yellow
set fish_color_match --background=brblue
set fish_color_normal normal
set fish_color_operator bryellow
set fish_color_param cyan
set fish_color_quote yellow
set fish_color_redirection brblue
set fish_color_search_match bryellow '--background=brblack'
set fish_color_selection white --bold '--background=brblack'
set fish_color_status red
set fish_color_user brgreen
set fish_color_valid_path --underline

function fish_greeting
  printf "Hello, josef, how are you today?"
end

function fish_prompt
  echo
  printf '%s%s%s%s%s ' (whoami)
  set_color $fish_color_cwd
  echo -n (prompt_pwd)\n
  set_color normal
  echo '> '
end

function fish_right_prompt
#intentionally left blank
end

# kill processes by port
function kp --argument port
  set pid (lsof -t -i :$port)
  if test -z "$pid"
    echo "nothing running on this port"
    return 1
  end
  command kill -9 
end

function notes
  code -n ~/Documents/notes
end

function cpl
  echo "remember the cc function to go to ~/github.com"
  cd ~/Documents/playground
end
function cpr
  echo "remember the cc function to go to ~/github.com"
  cd ~/Documents/projects
end
function cdd
  cd ~/Documents
end

function reload
  command reset
  source ~/.config/fish/config.fish
end

function r --argument count
  set -q count[1]
  or set count 10
  command ls -aldt * | head -$count
end

function cc --argument repo
  cd ~/github.com/$repo
end