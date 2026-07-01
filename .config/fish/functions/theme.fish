function theme --description "Switch color theme across ghostty, lazygit, and neovim"
    set -l available \
        mellow \
        embark \
        everforest \
        kanagawa-wave \
        kanagawa-dragon \
        kanagawa-lotus

    set -l current (set -q NVIM_COLORSCHEME; and echo $NVIM_COLORSCHEME; or echo mellow)

    if test (count $argv) -eq 0
        set -l i 1
        for t in $available
            if test $t = $current
                echo "$i. $t (current)"
            else
                echo "$i. $t"
            end
            set i (math $i + 1)
        end
        return 0
    end

    set -l name $argv[1]

    if not contains -- $name $available
        echo "unknown theme: $name"
        echo "available:"
        set -l i 1
        for t in $available
            echo "  $i. $t"
            set i (math $i + 1)
        end
        return 1
    end

    # Map fish theme name to ghostty's built-in theme name.
    # Declare before the switch so the variable is in function scope.
    set -l ghostty_name ""
    switch $name
        case mellow
            set ghostty_name Mellow
        case embark
            set ghostty_name Embark
        case everforest
            set ghostty_name "Everforest Dark Hard"
        case kanagawa-wave
            set ghostty_name "Kanagawa Wave"
        case kanagawa-dragon
            set ghostty_name "Kanagawa Dragon"
        case kanagawa-lotus
            set ghostty_name "Kanagawa Lotus"
    end

    # Ghostty: write in-place via python3 (preserves hardlink to dotfiles source)
    set -l ghostty_config ~/.config/ghostty/config
    python3 -c "
import sys
fn, name = sys.argv[1], sys.argv[2]
with open(fn) as f: lines = f.readlines()
lines = ['theme = ' + name + '\n' if l.startswith('theme = ') else l for l in lines]
with open(fn, 'w') as f: f.writelines(lines)
" $ghostty_config $ghostty_name
    echo "ghostty: $ghostty_name (open a new window to apply)"

    # Lazygit: write theme content in-place to preserve hardlink to dotfiles source
    set -l lg_themes ~/.config/lazygit/themes
    if not test -d $lg_themes
        set lg_themes ~/github.com/josefaidt/dotfiles/.config/lazygit/themes
    end
    if test -f $lg_themes/$name.yml
        cat $lg_themes/$name.yml > ~/.config/lazygit/config.yml
        echo "lazygit: $name"
    else
        echo "lazygit: theme file not found at $lg_themes/$name.yml"
    end

    # Neovim: set universal env var — new sessions pick this up via NVIM_COLORSCHEME.
    # Running sessions: use <leader>uc to switch live.
    set -Ux NVIM_COLORSCHEME $name
    echo "neovim: $name (new sessions; use <leader>uc to switch live)"
end
