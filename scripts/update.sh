# INSTALL PRETTIER
if
  [ ! -f .prettier.yml ]
then
  echo "$(tput setaf 2)::INSTALLING PRETTIER CONFIGS$(tput sgr 0)"
  echo -e "semi: false \ntrailingComma: \"none\" \narrowParens: \"avoid\" \nprintWidth: 150" > .prettierrc.yml
fi
# UPDATE ALL DATA FROM REPOSTORIES
echo "$(tput setaf 2)::UPDATE MAIN INFRA REPOSITORY$(tput sgr 0)"
git fetch
git pull --ff-only

echo "$(tput setaf 2)::UPDATE ALL SUBMODULES$(tput sgr 0)"
git submodule update --init --recursive -j 8
git submodule foreach 'git checkout master'
git submodule foreach 'git fetch'
git submodule foreach 'git pull --ff-only'
