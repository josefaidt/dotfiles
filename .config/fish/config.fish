if status --is-login
	set -gx PATH $PATH ~/bin ~/Documents/projects/.templates
    set --export PROJECTS ~/Documents/projects
    set --export FISH ~/.config/fish
    set --export PICS ~/Pictures
    set --export DOCS ~/Documents
    set --export -g NVM_DIR ~/.nvm
end

function fish_greeting
    printf "Hello, josef, how are you today?"
end

function fish_prompt
    # printf '%s@%s%s%s%s ' (whoami | cut -d . -f 1) (hostname | cut -d . -f 1 | cut -d '-' -f 2)
    printf '%s%s%s%s%s ' (whoami | cut -d . -f 1)
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal
    echo -n '> '
end

alias vl=vercel
alias vi=nvim

# need to install Fisher via `curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish`
# need to install bass via `fisher add edc/bass`
set LATEST_NVM (ls -t /usr/local/Cellar/nvm | head -1)
function nvm
    bass source /usr/local/Cellar/nvm/{$LATEST_NVM}/nvm.sh --no-use ';' nvm $argv
end

if test -e (pwd)/.nvmrc 
    nvm use
else
    nvm use default
end

# KILL PROCESS BY PORT
function kp
    command kill -9 (lsof -t -i :$argv[1])
end

function ywrs
    command yarn workspaces $argv
end
function ywr
    command yarn workspace $argv
end

function notes
    code -n ~/Documents/notes
end

function reload
    source ~/.config/fish/config.fish
end

function edit
    if test (count $argv) -lt 1; or test $argv[1] = "--help"
        # echo "What are you wanting to edit?"
        read -l -P "What are you wanting to edit? " file
        _edit_file $file
    else
        _edit_file $argv[1]
    end
end

set eslintfile ~/.config/.eslintrc.js
set fishfile ~/.config/fish/config.fish
function _edit_file
    set file $argv[1]
    switch $file
        case 'eslint'
            code $eslintfile
            echo 'Opening ESLint...'
        case 'fish'
            code $fishfile
            echo 'Opening fish config...'
        case 'notes'
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