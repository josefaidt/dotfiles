alias ay="amplify"
alias ayd="amplify-dev"
alias cda="cd ~/github.com/aws-amplify"
alias cpo="cd ~/Documents/projects/aws-amplify/reproductions"

function mkrep --argument name
  set repro ~/Documents/projects/aws-amplify/reproductions/$name
  mkdir $repro
  cd $repro
  code $repro
  # setup new amplify project
  amplify init -y
  # pull in the auto-git hooks
  rm -rf amplify/hooks
  gh gist clone git@gist.github.com:cd031d1f4b1eb375b937de0dc958fe9a.git amplify/hooks
  # set up git
  git init
end