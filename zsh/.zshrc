# =========================
# Path
# =========================
typeset -U path
path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.cargo/bin
  /usr/local/bin
  /usr/bin/vendor_perl
  $path
)

export WIKIMAN_LANG=en
export EDITOR='nvim'
export MANPAGER="nvim +Man!"

# =========================
# History
# =========================
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history hist_ignore_dups hist_ignore_space hist_verify
setopt inc_append_history share_history
setopt bang_hist

unsetopt beep
setopt autocd globdots interactivecomments

# =========================
# Completion
# =========================
autoload -Uz compinit
ZCOMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"
compinit -C -d "$ZCOMPDUMP"
[[ -f "$ZCOMPDUMP" ]] && zcompile "$ZCOMPDUMP"

zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-color yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# =========================
# Aliases - System
# =========================
alias sudo="sudo "
alias vim=nvim
alias cat="bat --theme=gruvbox-dark --pager=never"
alias ls=eza
alias l=ls
alias sl=ls
alias ll='eza -l'
alias la='eza -la'
alias tree='eza --tree'
alias open="mimeopen"
alias devour="devour"

# Safety / confirmations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias ln='ln -v'
alias mkdir='mkdir -pv'

# Disk / resource usage
alias df='df -h'
alias du='du -h'
alias du1='du -d 1 -h'
alias free='free -h'
alias mount='mount | column -t'

# grep -> ripgrep
alias grep='rg'
alias grepi='rg -i'
alias grepp='rg --pretty'

# =========================
# Aliases - Navigation
# =========================
alias mkcd='(){ mkdir -p "$1" && cd "$1" }'

# =========================
# Aliases - Git
# =========================
alias g=git
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcm='git commit -v -m'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull --rebase'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias gst='git stash'
alias gstp='git stash pop'
alias gr='git remote -v'
alias gcp='git cherry-pick'

# =========================
# Aliases - Package management
# =========================
alias p=paru
alias update='paru -Syu'
alias cleanup='paru -Qtdq | paru -Rns - 2>/dev/null || echo "Nothing to clean"'
alias search='paru -Ss'
alias info='paru -Qi'
alias files='paru -Ql'
alias orphans='paru -Qtd'

# =========================
# Aliases - Misc
# =========================
alias suspend="systemctl suspend"
alias nosleep='systemd-inhibit --what=sleep --why="Temporarily disabling suspend" bash'
alias cjp="create-java-project"
alias d=devour
alias t=tmux
alias tx="~/.scripts/tmux-sessionizer"
alias f='fzf'
alias fd='fd'
alias help='run-help'
alias zmv='noglob zmv'

(( $+commands[pipx] )) && eval "$(register-python-argcomplete pipx)" 2>/dev/null

# =========================
# Antidote Plugin Manager
# =========================
export ANTIDOTE_HOME="$HOME/.local/share/antidote"

source /usr/share/zsh-antidote/antidote.zsh

zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

source ${zsh_plugins}.zsh

# =========================
# History substring search keybinds
# =========================
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# =========================
# Autosuggest / Highlight Styling
# =========================
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7a8599'
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=none
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=green'

# =========================
# Prompt (async git + exit status)
# =========================
setopt PROMPT_SUBST
autoload -Uz vcs_info

zstyle ':vcs_info:git:*' formats ' %F{#af5fff}[%b]%f'

LAST_GIT_DIR=""
CACHED_GIT=""

update_git_cache() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    CURRENT_GIT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ "$CURRENT_GIT_DIR" != "$LAST_GIT_DIR" ]]; then
      LAST_GIT_DIR="$CURRENT_GIT_DIR"
      vcs_info
      CACHED_GIT="${vcs_info_msg_0_}"
    fi
  else
    LAST_GIT_DIR=""
    CACHED_GIT=""
  fi
}

async_git_update() {
  { update_git_cache; zle && zle reset-prompt } &!
}

precmd() {
  LAST_EXIT=$?
  async_git_update
}

prompt_symbol() {
  if [[ $EUID -eq 0 ]]; then
    echo "%F{#ff5f5f}#%f"
  elif [[ $LAST_EXIT -ne 0 ]]; then
    echo "%F{#ff5f5f}>%f"
  else
    echo "%F{#d8dee9}>%f"
  fi
}

PROMPT='%F{#5f87ff}%~%f${CACHED_GIT} $(prompt_symbol) '

# =========================
# Transient Prompt
# =========================
transient_prompt() {
  print -Pn "\r%F{#d8dee9}>%f "
}

zle-line-finish() {
  transient_prompt
}
zle -N zle-line-finish
