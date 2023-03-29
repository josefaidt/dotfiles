if status is-interactive
  # Commands to run in interactive sessions can go here
end

if status --is-login
  set --global --export PATH $PATH ~/.emacs.d/bin ~/bin /Users/josef/Library/Python/3.9/bin $HOME/.cargo/bin $HOME/bin/gradle-5.5.1/bin ~/.local/bin
  set --export PROJECTS ~/Documents/Projects
  set --export FISH ~/.config/fish
  set --export DOCS ~/Documents
  set --export QMK_HOME ~/qmk_firmware
  set --export JAVA_HOME /Library/Java/JavaVirtualMachines/jdk-18.0.1.1.jdk/Contents/Home
end

test -e (pwd)/.nvmrc && fnm use

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

alias mkcd="mkdir -p $1 && cd $1"
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

# KILL PROCESS BY PORT
function kp
  command kill -9 (lsof -t -i :$argv[1])
end

function notes
  code -n ~/Documents/notes
end

function cpl
  cd ~/Documents/playground
end
function cpr
  cd ~/Documents/projects
end
function cdd
  cd ~/Documents
end

function ts
  pnpm \
  --package=@types/node \
  --package=typescript \
  --package=ts-node \
  --silent \
  dlx ts-node $argv[1]
end

function tse
  pnpm \
  --package=@types/node \
  --package=typescript \
  --package=ts-node \
  --silent \
  dlx ts-node --esm $argv[1]
end

function edit
  if test (count $argv) -lt 1; or test $argv[1] = --help
      # echo "What are you wanting to edit?"
      read -l -P "What are you wanting to edit? " file
      _edit_file $file
  else
      _edit_file $argv[1]
  end
end

set fishfile ~/.config/fish/config.fish
function _edit_file
  set file $argv[1]
  switch $file
      case fish
          code -n $fishfile
          echo 'Opening fish config...'
      case notes
          notes
          echo 'Opening notebook...'
      case '*'
          echo "Doesn't look like I have that file, try again."
  end
end

function read_confirm
  while true
      read -l -P 'Do you want to continue? [y/N] ' confirm
      switch $confirm
          case Y y
              return 0
          case '' N n
              return 1
      end
  end
end

function reload
  command reset
  source ~/.config/fish/config.fish
end