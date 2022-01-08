# Path to your oh-my-zsh installation.
export ZSH="/home/csh4dow/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# ZSH_THEME=""

plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
)

source $ZSH/oh-my-zsh.sh

alias doas="doas "
alias irc=weechat
alias vim=nvim
alias ls="ls -h --color=yes --group-directories-first"
alias la="ls -lA"

## Advanced Tab Completion
autoload -U compinit
zstyle ':completion*' menu select
compinit
# _comp_options+=(globdots) # Include Hidden Files

export EDITOR='nvim'
export VISUAL='nvim'

ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# PS1="%F{red}[%F{yellow}%n%F{green}@%F{blue}%m %F{magenta}%1~%F{red}]%f$ "
PS1="%F{cyan}[%n@%m %1~]$%f "

ZVM_CURSOR_STYLE_ENABLED=false
