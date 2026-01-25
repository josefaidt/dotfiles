# ls -al but with eza
function la
  eza --all --long \
    --classify \
    --icons \
    --hyperlink \
    --group-directories-first \
    --no-user \
    --no-permissions \
    --no-filesize \
    --time-style long-iso \
    --header \
    $argv
end
