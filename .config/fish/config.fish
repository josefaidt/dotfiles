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

function eslint
    command eslint --config ~/.config/.eslintrc.js $argv
end

# need to install Fisher via `curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish`
# need to install bass via `fisher add edc/bass`
set LATEST_NVM (ls -t /usr/local/Cellar/nvm | head -1)
function nvm
    bass source /usr/local/Cellar/nvm/{$LATEST_NVM}/nvm.sh --no-use ';' nvm $argv
end

function fish_prompt
    # printf '%s@%s%s%s%s ' (whoami | cut -d . -f 1) (hostname | cut -d . -f 1 | cut -d '-' -f 2)
    printf '%s%s%s%s%s ' (whoami | cut -d . -f 1)
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal
    echo -n '> '
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

function reload
    source ~/.config/fish/config.fish
end

function yawn
    if test (count $argv) -lt 1; or test $argv[1] = "--help"
        printf "Don't yawn too loud now, I need a package name"
    else if test (count $argv) -gt 1
        switch $argv[1]
            case 'eslint'
                _install_eslint
            case 'gulp'
                _install_gulp
            case 'init'
                _init_my_project $argv
            case 'node'
                _install_latest_node
            case '*'
                echo "Doesn't look like I have that package, try again."
        end
    else
        echo $argv
    end
end

function _install_latest_node
    command nvm install node
    command nvm alias default node
    command nvm use default
end

function _install_eslint
    yarn add -D \
        eslint babel-eslint eslint-loader \
        prettier eslint-config-prettier eslint-plugin-prettier \
        eslint-config-standard eslint-plugin-standard \
        eslint-plugin-node \
        eslint-plugin-jsx-a11y \
        eslint-plugin-promise \
        eslint-plugin-import \
        eslint-plugin-react \
        eslint-plugin-react-hooks \
    ;and cp ~/.config/.eslintrc.js .
end

function _install_gulp
    yarn add -D gulp gulp-rename gulp-inline-css
    ;and cp ~/.config/gulpfile.js .
end
