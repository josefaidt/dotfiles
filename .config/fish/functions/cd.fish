# override cd to load environment variables from dotenv files
function cd
  builtin cd $argv
  loadenv --silent; or true
end
