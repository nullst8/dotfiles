# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/manas/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias vim=nvim
alias qpdfview="devour qpdfview"
alias sudo="sudo "
alias ls="exa --icons --group-directories-first"
alias lsl="exa --icons --group-directories-first -la"
alias sl="exa --icons --group-directories-first"
alias cp="cp -i"
alias cat="bat --theme gruvbox-dark"
alias emulator="~/Android/Sdk/emulator/emulator"
alias vlc="devour vlc"
alias gparted="devour gparted"
alias wine="devour wine"
alias feh="devour feh"
alias mpv="devour mpv"
alias lollypop="devour lollypop"
alias la='ls -a'
alias lh="ls -la | rg '^\.'"
alias ll='ls -la'
alias paru=yay
alias l='ls'
alias l.="ls | egrep --color=no '^\.'"
alias ssn="shutdown now"
alias rn="reboot"
alias ytmp3="youtube-dl -x --audio-format mp3"
alias df="df -h"

## Advanced Tab Completion
autoload -U compinit
zstyle ':completion*' menu select
compinit
_comp_options+=(globdots) # Include Hidden Files

export EDITOR='nvim'
export VISUAL='nvim'

alias update-grub="grub-mkconfig -o /boot/grub/grub.cfg"

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

bindkey '^H' backward-kill-word

alias "list.sh"="chsh -l | sed 's/^.*\///' | sort -u | grep -v git-shell"
