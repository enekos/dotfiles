# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

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
# DISABLE_AUTO_TITLE="true"

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



# Your SSH Key Name or Fingerprint (as it appears in Hetzner Cloud)

# ─── GCloud Log Helpers (join-production-339308) ────────────────────────────
_JL_PROJECT="join-production-339308"
# Core services watched by jlfire / used as default scope when no service given
_JL_CORE='resource.labels.container_name=("data" OR "search" OR "screening-questions-v2" OR "issue-reports" OR "job-ad-app" OR "job-ad-app-cache-invalidation" OR "jobs" OR "sitemap" OR "smart-jobs" OR "auth-app" OR "payments" OR "invoices" OR "customer" OR "subscriptions")'

# _jl_svc_filter <maybe-svc> — returns a GCP filter fragment for the service,
# or the core-services filter when the arg looks like a time value or is empty.
function _jl_svc_filter() {
  if [[ -z "$1" || "$1" =~ ^[0-9]+[smhd]$ ]]; then
    echo "$_JL_CORE"
  else
    echo "resource.labels.container_name=\"$1\""
  fi
}

# jl [service] [freshness] [limit]
# Pretty log table. Omit service to query all core services.
# Examples: jl data 30m 100 | jl 1h | jl
function jl() {
  local svc_filter freshness limit
  if [[ -z "$1" || "$1" =~ ^[0-9]+[smhd]$ ]]; then
    svc_filter="$_JL_CORE"; freshness="${1:-1h}"; limit="${2:-50}"
  else
    svc_filter="resource.labels.container_name=\"$1\""; freshness="${2:-1h}"; limit="${3:-50}"
  fi
  gcloud logging read "$svc_filter" \
    --project="$_JL_PROJECT" \
    --freshness="$freshness" \
    --limit="$limit" \
    --format=json \
    | jq -r '.[] | [.timestamp, .resource.labels.container_name, (.jsonPayload.level // .severity), (.jsonPayload.message // .textPayload // "(no message)")] | @tsv' \
    | column -t -s $'\t'
}

# jle [service] [freshness] [limit]
# ERROR+ logs with full jsonPayload. Omit service for all core services.
# Examples: jle data 6h | jle 1h | jle
function jle() {
  local svc_filter freshness limit
  if [[ -z "$1" || "$1" =~ ^[0-9]+[smhd]$ ]]; then
    svc_filter="$_JL_CORE AND severity>=ERROR"; freshness="${1:-1h}"; limit="${2:-50}"
  else
    svc_filter="resource.labels.container_name=\"$1\" AND severity>=ERROR"; freshness="${2:-1h}"; limit="${3:-50}"
  fi
  gcloud logging read "$svc_filter" \
    --project="$_JL_PROJECT" \
    --freshness="$freshness" \
    --limit="$limit" \
    --format=json \
    | jq '.[] | {time: .timestamp, svc: .resource.labels.container_name, severity, msg: (.jsonPayload.message // .textPayload), payload: .jsonPayload}'
}

# jlf [service] <query> [freshness] [limit]
# Search logs by text/regex. Omit service to search all core services.
# Examples: jlf data "traceId" 24h | jlf "ECONNRESET" 2h | jlf "userId"
function jlf() {
  local svc_filter query freshness limit
  # If $2 is set and doesn't look like a time value, $1 is a service name
  if [[ -n "$2" && ! "$2" =~ ^[0-9]+[smhd]$ ]]; then
    svc_filter="resource.labels.container_name=\"$1\""; query="$2"; freshness="${3:-1h}"; limit="${4:-50}"
  else
    svc_filter="$_JL_CORE"; query="${1:?Usage: jlf [service] <query> [freshness] [limit]}"; freshness="${2:-1h}"; limit="${3:-50}"
  fi
  gcloud logging read \
    "$svc_filter AND (textPayload=~\"$query\" OR jsonPayload.message=~\"$query\")" \
    --project="$_JL_PROJECT" \
    --freshness="$freshness" \
    --limit="$limit" \
    --format=json \
    | jq '.[] | {time: .timestamp, svc: .resource.labels.container_name, severity, msg: (.jsonPayload.message // .textPayload), payload: .jsonPayload}'
}

# jltrace <traceId> [freshness]
# All logs across all services for a given traceId, sorted by time.
# Example: jltrace d280a259439aa00d78271192841a57a2 1h
function jltrace() {
  local trace="${1:?Usage: jltrace <traceId> [freshness=1h]}"
  local freshness="${2:-1h}"
  gcloud logging read \
    "jsonPayload.traceInfo.traceId=\"$trace\"" \
    --project="$_JL_PROJECT" \
    --freshness="$freshness" \
    --limit=200 \
    --format=json \
    | jq -r '.[] | [.timestamp, .resource.labels.container_name, (.jsonPayload.level // .severity), (.jsonPayload.message // .textPayload // "(no message)")] | @tsv' \
    | sort \
    | column -t -s $'\t'
}

# jlraw [service] [freshness] [limit]
# Full raw JSON entries, no truncation. Omit service for all core services.
# Examples: jlraw data 30m 5 | jlraw 15m 3
function jlraw() {
  local svc_filter freshness limit
  if [[ -z "$1" || "$1" =~ ^[0-9]+[smhd]$ ]]; then
    svc_filter="$_JL_CORE"; freshness="${1:-1h}"; limit="${2:-20}"
  else
    svc_filter="resource.labels.container_name=\"$1\""; freshness="${2:-1h}"; limit="${3:-20}"
  fi
  gcloud logging read "$svc_filter" \
    --project="$_JL_PROJECT" \
    --freshness="$freshness" \
    --limit="$limit" \
    --format=json
}
# jlfire [freshness] [limit]
# Firefighting dashboard: all ERROR logs across core services, deduped and formatted.
# Example: jlfire 1h        (last hour, up to 300 errors)
#          jlfire 30m 500
function jlfire() {
  local freshness="${1:-1h}"
  local limit="${2:-300}"

  local FILTER='severity=ERROR AND resource.labels.container_name=("data" OR "search" OR "screening-questions-v2" OR "issue-reports" OR "job-ad-app" OR "job-ad-app-cache-invalidation" OR "jobs" OR "sitemap" OR "smart-jobs" OR "auth-app" OR "payments" OR "invoices" OR "customer" OR "subscriptions")'

  echo "🔥 Fetching production errors (last $freshness, up to $limit)..." >&2

  gcloud logging read "$FILTER" \
    --project="$_JL_PROJECT" \
    --freshness="$freshness" \
    --limit="$limit" \
    --format=json \
  | jq -r --arg f "$freshness" '
    def clean_stack:
      if . == null then ""
      else
        split("\n")
        | map(select(
            ( test("node_modules") or test("processTicksAndRejections") or
              test("node:internal") or test("AsyncLocalStorage") or
              test("contextWrapper") or test("at process\\.") ) | not
          ))
        | map(ltrimstr("    ") | ltrimstr("  "))
        | .[0:7]
        | map("      " + .)
        | join("\n")
      end;

    def fmt_time:
      split("T") | "\(.[0]) \(.[1] | split(".")[0])";

    . as $all |

    # ── Header ──────────────────────────────────────────────────────────────
    "\u001b[1m\u001b[31m══════════════════════════════════════════════════════════\u001b[0m",
    "\u001b[1m\u001b[31m🔥  FIREFIGHTING\u001b[0m\u001b[1m  ·  last \($f)  ·  \(length) total errors\u001b[0m",
    "\u001b[1m\u001b[31m══════════════════════════════════════════════════════════\u001b[0m",
    "",

    # ── Per-service breakdown ────────────────────────────────────────────────
    "\u001b[1m  ERRORS BY SERVICE\u001b[0m",
    (
      group_by(.resource.labels.container_name)
      | sort_by(-length)
      | .[]
      | (length) as $n
      | ( [ range( [($n / 2 | floor), 30] | min ) ] | map("█") | join("") ) as $bar
      | "    \u001b[33m\(.[0].resource.labels.container_name)\u001b[0m  \u001b[31m\($bar)\u001b[0m \($n)"
    ),
    "",
    "\u001b[2m  ── Unique error groups, sorted by frequency ──────────────────────────\u001b[0m",

    # ── Deduped errors ───────────────────────────────────────────────────────
    (
      group_by(.resource.labels.container_name + "||" + (.jsonPayload.message // .textPayload // ""))
      | sort_by(-length)
      | .[]
      | . as $grp
      | $grp[0] as $e
      | ($e.jsonPayload.message // $e.textPayload // "(no message)") as $msg
      | ($e.jsonPayload.error.stack // $e.jsonPayload.payload.stack // null) as $rawstack
      | ($e.jsonPayload.error.message // $e.jsonPayload.payload.message // null) as $innerMsg
      | ($e.jsonPayload.traceInfo // {}) as $trace
      | ($e.timestamp | fmt_time) as $time
      | ($grp | length) as $cnt
      |
      "",
      "\u001b[2m  ──────────────────────────────────────────────────────────────────\u001b[0m",
      "  \u001b[31m[×\($cnt)]\u001b[0m \u001b[1m\u001b[33m\($e.resource.labels.container_name)\u001b[0m  \u001b[1m\($msg)\u001b[0m",
      "         \u001b[2m\($time)  ·  pod: \($e.resource.labels.pod_name)\u001b[0m",
      (if $trace.transactionName  then "         \u001b[2mTransaction:\u001b[0m \($trace.transactionName)"                    else empty end),
      (if $trace.traceId          then "         \u001b[2mTrace:\u001b[0m      \u001b[36m\($trace.traceId)\u001b[0m  \u001b[2m→ jltrace \($trace.traceId)\u001b[0m" else empty end),
      (if $innerMsg != null and $innerMsg != $msg
                                  then "         \u001b[2mCause:\u001b[0m      \u001b[31m\($innerMsg)\u001b[0m"                else empty end),
      (if $rawstack != null and ($rawstack | clean_stack) != ""
                                  then "         \u001b[2mStack:\u001b[0m\n\u001b[2m\($rawstack | clean_stack)\u001b[0m"    else empty end)
    ),
    "",
    "\u001b[1m\u001b[31m══════════════════════════════════════════════════════════\u001b[0m"
  '
}
# ────────────────────────────────────────────────────────────────────────────

# (Optional) Inject LLM API keys for the AI workers


# ==========================================
# Power User Tools & Aliases
# ==========================================
alias ls="eza --icons --git"
alias ll="eza --icons --git -la"
alias cat="bat"

# Setup fzf shell integration
source <(fzf --zsh)

# Source secrets if they exist
if [ -f ~/.zsecrets ]; then
    source ~/.zsecrets
fi

# Initialize starship prompt
eval "$(starship init zsh)"
