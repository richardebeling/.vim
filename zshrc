# config before omz is loaded:
# ZSH_THEME="gentoo"
# plugins=()
# at the end of .zshrc:
# source ~/.vim/zshrc

# mate-terminal sets this (and setting it makes the gnome keyring work)
SSH_AUTH_SOCK=/run/user/1000/keyring/ssh

# Dont share history between sessions
unsetopt share_history
HISTSIZE=1000000
SAVEHIST=1000000

# Command aliasses
alias caja='caja "$PWD"'
alias rg="rg -S --hidden"
alias gd="git diff -- ':!package-lock.json' ':!yarn.lock'"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PYENV
export PYENV_ROOT="$HOME/software/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Don't show changes in the current dir just because there are untracked files
export DISABLE_UNTRACKED_FILES_DIRTY=true

# Use vim by default
export VISUAL=vim
export EDITOR="$VISUAL"

_gen_fzf_default_opts() {
  local base2="#eee8d5"
  local yellow="#b58900"

  export FZF_DEFAULT_OPTS="
    --color fg:-1,bg:-1,hl:4,fg+:$base2,bg+:0,hl+:4
    --color info:$yellow,prompt:$yellow,pointer:-1,marker:-1,spinner:$yellow
    --bind alt-a:select-all,alt-d:deselect-all,alt-t:toggle-all
  "
  export FZF_DEFAULT_COMMAND="rg --files --hidden"
  # Gruvbox colors
  # export FZF_DEFAULT_OPTS="
  #   --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  #   --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
  #   --bind alt-a:select-all,alt-d:deselect-all,alt-t:toggle-all
  # "
}
_gen_fzf_default_opts
