# config before omz is loaded:
# ZSH_THEME="gentoo"
# plugins=()
# at the end of .zshrc:
# source ~/.vim/zshrc

# Dont share history between sessions
unsetopt share_history
HISTSIZE=1000000
SAVEHIST=1000000

# Command aliasses
alias rg="rg -S --hidden"
alias vim="nvim"

export VISUAL=nvim
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
}
_gen_fzf_default_opts

# omz VCS status function used by the gentoo theme, modified to respect hide-dirty flag
# https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/gentoo.zsh-theme#L15
+vi-untracked-git() {
  if [[ "$(__git_prompt_git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if command git status --porcelain 2>/dev/null | command grep -q '??'; then
      hook_com[misc]='%F{red}?'
    else
      hook_com[misc]=''
    fi
  fi
}

# nix: https://nixos.wiki/wiki/Locales
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
