# trash
apt update
apt install zsh

echo 'export TERM=xterm-256color' >> ~/.zshrc
source ~/.zshrc

# zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

source ~/.zshrc

# >> .zshrc

