#!/usr/bin/env bash
set -ex

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

sudo apt install curl htop ripgrep fzf neovim zsh tmux git-delta clangd python3 pipx

pipx install python-lsp-server ruff

# tmux resurrect
git clone https://github.com/tmux-plugins/tmux-resurrect.git ~/.vim/tmux-resurrect || true
git -C ~/.vim/tmux-resurrect switch -d cff343cf9e81983d3da0c8562b01616f12e8d548

# vim plugins
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/9ef7739c81233608af0c1bb103210a83e409a10f/plug.vim
  nvim +PlugInstall +qall
fi

mkdir -p $HOME/.config/nvim
ln -fs "$SCRIPT_DIR/nvim_init.vim" "$HOME/.config/nvim/init.vim"

mkdir -p $HOME/.config/tmux
ln -fs "$SCRIPT_DIR/tmux.conf" "$HOME/.config/tmux/tmux.conf"

mkdir -p $HOME/.config/git
ln -fs "$SCRIPT_DIR/gitconfig" "$HOME/.config/git/config"

if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  sed -i 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="gentoo"/g' ~/.zshrc
  sed -i 's/^plugins=(git)/plugins=()/g' ~/.zshrc
  grep -qxF 'source ~/.vim/zshrc' ~/.zshrc || echo 'source ~/.vim/zshrc' >> ~/.zshrc
fi

# git -C ~/path/to/repo config oh-my-zsh.hide-dirty 1    # fix sluggish shell on large repos
# git -C ~/path/to/repo maintenance start                # git large repo optimizations
# cp ~/.ignore ~/path/to/repo # .ignore file in repo
