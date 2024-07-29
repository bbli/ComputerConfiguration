#!/usr/bin/env fish
## 0. Manually install these first
## neovim
## emacs
## fish
## Nerd Font-link from starship(wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/SourceCodePro.zip)
## 1. Stow all symlinks
stow -t ~/ --adopt .

## 2. Fish Shell Plugins(source will create a fish function called "fisher")
#source <(curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish) && fisher install jorgebucaran/fisher 
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher install jethrokuan/z
## 3. Tmux plugins(press prefix-I afterwards)
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

## 4. Install rust and some cargo packages for neovim/emacs/fish alias
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
~/.cargo/bin/cargo install ripgrep
~/.cargo/bin/cargo install fd
~/.cargo/bin/cargo install fd-find
~/.cargo/bin/cargo install exa
# make sure to install nerd font first
~/.cargo/bin/cargo install starship

## 5. Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
