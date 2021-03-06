HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch
unsetopt beep

autoload -Uz compinit && compinit
zstyle ':completion*' menu select
compinit
# _comp_options+=(globdots) # Include Hidden Files

export EDITOR='nvim'
export VISUAL='nvim'

alias sudo="sudo "
alias doas="doas "
alias l="ls"
alias p="paru"
alias zathura="devour zathura"
alias sxiv="devour sxiv"
alias irc=weechat
alias vim=nvim
alias cmatrix=ncmatrix
alias cat="bat --theme=gruvbox-dark"
alias ls="exa --group-directories-first"
alias la="ls -la"
alias bctl="bluetoothctl"

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

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# PS1="%F{#689d6a}%B[%n@%m %1~]$%b%f "
PS1="%F{#cc241d}%B[%F{#98971a}%n%F{#689d6a}@%F{#b16286}%m %F{#d65d0e}%1~%F{#cc241d}]%F{#689d6a}$%f%b "

# Plugins
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-sudo/sudo.plugin.zsh
GOPATH=/home/csh4dow/.go
export GOPATH
PATH=$PATH:$GOPATH/bin # Add GOPATH/bin to PATH for scripting
PATH=$PATH:/home/csh4dow/.local/bin

fuck() {
echo "\n"
echo "                               \$\$\$\$"
echo "                             \$\$    \$\$"
echo "                             \$\$    \$\$"
echo "                             \$\$    \$\$"
echo "                             \$\$    \$\$"
echo "                             \$\$    \$\$"
echo "                         \$\$\$\$\$\$    \$\$\$\$\$\$"
echo "                       \$\$    \$\$    \$\$    \$\$\$\$"
echo "                       \$\$    \$\$    \$\$    \$\$  \$\$"
echo "               \$\$\$\$\$\$  \$\$    \$\$    \$\$    \$\$    \$\$"
echo "               \$\$    \$\$\$\$                \$\$    \$\$"
echo "               \$\$      \$\$                      \$\$"
echo "                 \$\$    \$\$                      \$\$"
echo "                  \$\$\$  \$\$                      \$\$"
echo "                   \$\$                          \$\$"
echo "                    \$\$\$                        \$\$"
echo "                     \$\$                      \$\$\$"
echo "                      \$\$\$                    \$\$"
echo "                       \$\$                    \$\$"
echo "                        \$\$\$                \$\$\$"
echo "                         \$\$                \$\$"
echo "                         \$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$"
echo "\n"
}

autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line
