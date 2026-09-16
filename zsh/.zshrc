# =====================================================================
# zshrc — nullst8
# Managed in ~/.dotfiles/zsh; symlinked from ~/.zshrc
# =====================================================================

# =========================
# Environment & Path
# =========================
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

typeset -U path
path=(
  "$DOTFILES/scripts"
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.local/share/pnpm"
  $path  # unquoted: quoted array expansion would join into a single broken word
)

export WIKIMAN_LANG=en
export EDITOR='nvim'
export MANPAGER="nvim +Man!"

# bat theme (applies to `bat` and the `cat` alias below)
export BAT_THEME='Catppuccin Mocha'

# GNU ls colors; also feeds completion list-colors below
(( $+commands[dircolors] )) && eval "$(dircolors -b)"

# =========================
# Options & History
# =========================
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt extended_history hist_ignore_dups hist_ignore_space hist_verify
setopt inc_append_history share_history hist_reduce_blanks hist_expire_dups_first
setopt bang_hist autocd globdots interactivecomments
unsetopt beep

# =========================
# Completion
# =========================
autoload -Uz compinit

# Rebuild the completion cache at most once a day; otherwise use the fast path.
# Kept in the XDG cache dir (not $HOME) so dumps don't clutter the home folder.
ZCOMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
mkdir -p -- ${ZCOMPDUMP:h}
if [[ ! -f $ZCOMPDUMP || -n ${ZCOMPDUMP}(#qN.mh+24) ]]; then
  compinit -d "$ZCOMPDUMP"
else
  compinit -C -d "$ZCOMPDUMP"
fi
[[ -f $ZCOMPDUMP ]] && zcompile "$ZCOMPDUMP"

zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-color yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# =========================
# Plugins (antidote)
# =========================
export ANTIDOTE_HOME="$HOME/.antidote"

# Prefer distro package, then user install, then command on PATH.
if [[ -f /usr/share/zsh-antidote/antidote.zsh ]]; then
  source /usr/share/zsh-antidote/antidote.zsh
elif [[ -f $ANTIDOTE_HOME/antidote.zsh ]]; then
  source $ANTIDOTE_HOME/antidote.zsh
elif (( $+commands[antidote] )); then
  source "$(antidote home)/antidote.zsh"
else
  print -u2 "antidote not found — install it or set ANTIDOTE_HOME manually"
fi

# Plugin config (must be set BEFORE the plugins are sourced)
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7a8599'
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=none
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=green'

# Bundle & source plugins (re-bundle when the plugin list changed or the
# bundle is empty/truncated — e.g. a previous failed run)
zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt
if [[ ! -s ${zsh_plugins}.zsh || ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# fzf shell integration: Ctrl-R history, Ctrl-T file picker, Alt-C smart cd
(( $+commands[fzf] )) && eval "$(fzf --zsh)"

# =========================
# Keybinds
# =========================
# History substring search: arrows (insert) + j/k (normal mode)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# =========================
# Prompt (synchronous git info + exit status)
# =========================
setopt PROMPT_SUBST
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:git:*' formats ' %F{#af5fff}[%b]%f'

_prompt_vcs() { vcs_info }
add-zsh-hook precmd _prompt_vcs

# Indicator flips direction with the vi mode (❯ insert / ❮ normal)
_zvm_prompt_char='❯'
function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL) _zvm_prompt_char='❮' ;;
    *)                _zvm_prompt_char='❯' ;;
  esac
}

# ❯ green on success / red on failure; red # when root
PROMPT='%F{#8be9fd}%n@%m%f %F{#bd93f9}%~%f${vcs_info_msg_0_} %(!.%F{#ff5f5f}#.%(?.%F{#50fa7b}.%F{#ff5f5f})${_zvm_prompt_char})%f '

# =========================
# Aliases — System
# =========================
alias sudo="sudo "          # trailing space lets aliases expand after sudo
alias vim=nvim
alias open="xdg-open"
alias oc=opencode
alias cat="bat --pager=never"

# ls → eza
alias ls=eza
alias l=ls
alias sl=ls
alias ll='eza -l'
alias la='eza -la'
alias tree='eza --tree'

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

# grep → ripgrep
alias grep='rg'
alias grepi='rg -i'
alias grepp='rg --pretty'

# =========================
# Aliases — Navigation
# =========================
mkcd() { mkdir -p -- "$1" && cd -- "$1" }

# =========================
# Aliases — Git
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
# Aliases — Package management (paru)
# =========================
alias p=paru
alias update='paru -Syu'
alias cleanup='paru -Qtdq | paru -Rns - 2>/dev/null || echo "Nothing to clean"'
alias search='paru -Ss'
alias info='paru -Qi'
alias files='paru -Ql'
alias orphans='paru -Qtd'

# =========================
# Aliases — Misc
# =========================
alias suspend="systemctl suspend"
alias nosleep='systemd-inhibit --what=sleep --why="Temporarily disabling suspend" bash'
alias t=tmux
alias tx="tmux-sessionizer"
alias f='fzf'

# run-help / zmv are autoloadable zsh functions, not commands
autoload -Uz run-help zmv
unalias run-help 2>/dev/null   # zsh pre-aliases run-help to man
alias help='run-help'
alias zmv='noglob zmv'

# pipx shell completion
(( $+commands[pipx] )) && eval "$(register-python-argcomplete pipx)" 2>/dev/null

# =========================
# fnm (Node version manager)
# =========================
# Ephemeral session env is generated here — never hardcode the multishell
# path. --use-on-cd auto-switches Node via .nvmrc / .node-version.
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --version-file-strategy=local --shell zsh)"
