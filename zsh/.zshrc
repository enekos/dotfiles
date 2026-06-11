# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Put rustup before homebrew
export PATH="$HOME/.cargo/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="lambda"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(fnm env --use-on-cd --shell zsh)"
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

eval "$(zoxide init zsh)"

# Setup fzf shell integration
source <(fzf --zsh)

# Source secrets if they exist
if [ -f ~/.zsecrets ]; then
    source ~/.zsecrets
fi

# Initialize starship prompt
eval "$(starship init zsh)"

# Ripgrep Configuration Path
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export ONNX_PATH=/opt/homebrew/opt/onnxruntime/lib/libonnxruntime.dylib

# Pi
export PATH="/Users/enekosarasola/.local/share/fnm/node-versions/v25.8.1/installation/bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

