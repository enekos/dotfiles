# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Put rustup before homebrew
export PATH="$HOME/.cargo/bin:$PATH"

# ==========================================
# Completion + history (formerly provided by oh-my-zsh)
# ==========================================
# Brew site-functions (_git, etc.) + zz's _zz completion, then init compinit.
fpath=(/opt/homebrew/share/zsh/site-functions ~/.zsh/completions $fpath)
# compinit's security audit + dump rebuild costs ~220ms. Do the full pass only
# once every 24h (when the dump is stale); use the cached dump (-C) otherwise.
autoload -Uz compinit
_zdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n "$_zdump"(#qN.mh+24) ]]; then
  compinit -d "$_zdump"        # stale (>24h): re-audit + rebuild the dump
else
  compinit -C -d "$_zdump"     # fresh: trust the dump, skip the slow audit
fi
# Wordcode-compile the dump in the background so the next shell loads it faster.
{ [[ ! -s "$_zdump.zwc" || "$_zdump" -nt "$_zdump.zwc" ]] && zcompile -R -- "$_zdump" } &!
unset _zdump

# --- cached tool init ────────────────────────────────────────────────────────
# fnm/zoxide/fzf/starship all just PRINT static shell code; spawning them on
# every startup is the main cold-start cost. Cache each tool's output (compiled
# to .zwc) and rebuild only when the tool binary — or this rc — is newer.
# 4 subprocess forks per shell → 4 fast `source`s. To force a refresh after a
# manual tweak: `rm -rf ~/.cache/zsh-init`.
_evalcache() {
  # NB: do NOT `emulate -L zsh` here — that makes setopt local to this function,
  # which would revert the `setopt promptsubst` that starship's init runs while
  # being sourced, leaving PROMPT showing a literal $(starship prompt …).
  local name=$1; shift
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init/$name.zsh
  if [[ ! -s $cache || $commands[$1] -nt $cache || ${${(%):-%N}:A} -nt $cache ]]; then
    mkdir -p $cache:h
    "$@" >| $cache 2>/dev/null
    zcompile -R -- $cache 2>/dev/null
  fi
  source $cache
}

# History — mirror oh-my-zsh's sensible defaults so ~/.zsh_history persists.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE \
       HIST_REDUCE_BLANKS EXTENDED_HISTORY INC_APPEND_HISTORY
setopt interactive_comments

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias yt="yarn test"
alias gc="git commit -m"
alias gco="git checkout"
alias gp="git push"
alias gn="git checkout -b"
alias gd="git diff HEAD --"
alias ct="yarn env:test jest --bail --findRelatedTests \$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\\.(ts|tsx)$' | tr '\\n' ' ') \$(git diff --name-only --diff-filter=ACMR | grep -E '\\.(ts|tsx)$' | tr '\\n' ' ')"
alias ldr="lazydocker"

PATH="$HOME/.local/bin:$PATH"

_evalcache fnm fnm env --use-on-cd --shell zsh
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export META_DIR="$HOME/src/meta"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section


# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Production gcloud log helpers (jl/jle/jlf/jltrace/jlraw/jlfire) live OUTSIDE
# this public repo — they carry the prod project id + service names.
# File is in $HOME, not version-controlled. See ~/.gcloud-logs.zsh.
[ -f ~/.gcloud-logs.zsh ] && source ~/.gcloud-logs.zsh

# ==========================================
# Power User Tools & Aliases
# ==========================================
# --- eza (modern ls) ---
alias ls="eza --icons --git"
alias ll="eza --icons --git -la"
alias la="eza --icons --git -a"
alias lt="eza --icons --git --tree --level=2"          # 2-level tree
alias ltt="eza --icons --git --tree --level=4"         # deeper tree
alias lg="eza --icons --git -la --git --sort=modified" # newest last, git status

# --- bat (modern cat) ---
alias cat="bat"
alias catp="bat -pp"                                    # plain, no decorations/pager

# --- fd / ripgrep (modern find/grep) ---
alias ff="fd --hidden --follow"                         # find files
alias rgi="rg -i"                                       # case-insensitive search

# --- neovim ---
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# --- git (delta-aware shortcuts on top of the git plugin) ---
alias gs="git status -sb"
alias ga="git add"
alias gaa="git add -A"
alias gl="git log --oneline --graph --decorate -20"
alias gla="git log --oneline --graph --decorate --all -30"
alias gsw="git switch"
alias gst="git stash"
alias gstp="git stash pop"
alias gundo="git reset --soft HEAD~1"                   # uncommit, keep changes
alias gwip='git add -A && git commit -m "wip" --no-verify'

# --- GitHub CLI ---
alias ghpr="gh pr create --fill"
alias ghprv="gh pr view --web"
alias ghco="gh pr checkout"
alias ghs="gh pr status"

# --- tmux ---
alias ta="tmux attach -t"
alias tn="tmux new -s"
alias tl="tmux ls"
alias tk="tmux kill-session -t"

# --- package managers / runtimes ---
alias p="pnpm"
alias pi="pnpm install"
alias pd="pnpm dev"
alias bx="bunx"
alias uvr="uv run"

# --- docker ---
alias ldr="lazydocker"

# --- misc tooling ---
alias mairu="/Users/enekosarasola/mairu/mairu/bin/mairu"
alias lot="/Users/enekosarasola/eneko_projects/lotura/lotura -dir /Users/enekosarasola/thinking-os"
alias reload="exec zsh"                                 # reload shell
alias path='echo $PATH | tr ":" "\n"'                   # readable $PATH

# --- fzf-powered helpers ---
# fcd: fuzzy-cd into any subdirectory (uses fd + fzf + zoxide)
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git | fzf +m) && cd "$dir"
}
# fco: fuzzy git branch checkout (local + remote)
fco() {
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/.* //; s#remotes/[^/]*/##' \
    | sort -u | fzf +m) && git switch "$branch" 2>/dev/null || git switch -c "$branch"
}
# fkill: fuzzy-pick a process and kill it
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}') && echo "$pid" | xargs kill -"${1:-9}"
}
# fh: fuzzy-search shell history and run the selection
fh() {
  local cmd
  cmd=$(fc -rl 1 | fzf +s --tac | sed -E 's/ *[0-9]+\*? +//') && print -z "$cmd"
}

_evalcache zoxide zoxide init zsh
# zz ships its own completion (_zz on $fpath, via ~/.zsh/completions);
# it completes dirs + @branch + -w branches + flags. Don't rebind zz to zoxide's
# dir-only completer here, or it overrides _zz.


# Setup fzf shell integration
_evalcache fzf fzf --zsh

# Source secrets if they exist
if [ -f ~/.zsecrets ]; then
    source ~/.zsecrets
fi

# Initialize starship prompt
_evalcache starship starship init zsh

# Ripgrep Configuration Path
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export ONNX_PATH=/opt/homebrew/opt/onnxruntime/lib/libonnxruntime.dylib

# Pi
export PATH="/Users/enekosarasola/.local/share/fnm/node-versions/v25.8.1/installation/bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true
