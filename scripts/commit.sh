echo "$(tput setaf 2)::COMMIT AND PUSH CHANGES, PLEASE INSERT MESSAGE:$(tput sgr 0)"
read MESSAGE
git add --all
git commit -m "[Project] - ${MESSAGE}"
git push
