# override cd to load environment variables from dotenv files
function cd
  builtin cd $argv
  if status is-interactive
    loadenv --silent; or true
  end
end
