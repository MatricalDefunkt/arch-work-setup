# Uncomment for profiling: zmodload zsh/zprof

# ------------------------------------------------------------------------------
#                            ENVIRONMENT & PATH
# ------------------------------------------------------------------------------
# Set this before sourcing Oh My Zsh to avoid slowness with compinit.
ZSH_DISABLE_COMPFIX="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_AUTO_TITLE="true"
export EDITOR=nano
export VULTR_API_KEY="" # Enter your Vultr API key here

# Oh My Zsh installation path.
export ZSH="$HOME/.oh-my-zsh"

# Bun configuration.
export BUN_INSTALL="$HOME/.bun"

# Set the PATH, adding custom binary locations.
# Order is important: later additions are prepended and searched first.
path=(
  "$HOME/.cargo/bin"
  "$BUN_INSTALL/bin"
  "$HOME/flutter/bin"
  $path
)

# Miscellaneous environment variables.
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
export TERMINFO=/usr/share/terminfo
export DOCKER_BUILDKIT=1
export BW_SESSION="" # Enter your Bitwarden session key here
export PATH=$PATH:/opt/apache-spark/bin:/opt/docker-desktop/bin
export SPARK_HOME=/opt/apache-spark/

export COWPATH="/usr/share/cowsay/cows"

# ------------------------------------------------------------------------------
#                             ZSH & OH MY ZSH
# ------------------------------------------------------------------------------
# Oh My Zsh plugins - removed zsh-256color as it's causing 87% of startup time
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)

# Enable 256 colors manually (much faster than zsh-256color plugin)
# export TERM="xterm-256color"


# Load Oh My Zsh.
source "$ZSH/oh-my-zsh.sh"

# ------------------------------------------------------------------------------
#                             FRAMEWORK INIT
# ------------------------------------------------------------------------------
# Initialize Starship prompt.
eval "$(starship init zsh)"

# Lazy load Pyenv - only initialize when pyenv command is actually used
if [[ -d "$HOME/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  
  pyenv() {
    unset -f pyenv
    eval "$(command pyenv init --path)"
    eval "$(command pyenv init - zsh)"
    pyenv "$@"
  }
fi

# Initialize Conda lazily.
if [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]]; then
  source /opt/miniconda3/etc/profile.d/conda.sh
fi

# Lazy load NVM - only initialize when nvm/node/npm commands are used
export NVM_DIR="$HOME/.nvm"
if [[ -s "/usr/share/nvm/nvm.sh" ]]; then
  # Add node to path if default version exists
  [[ -d "$NVM_DIR/versions/node" ]] && export PATH="$NVM_DIR/versions/node/$(ls -1 $NVM_DIR/versions/node | tail -1)/bin:$PATH"
  
  # Lazy load function
  nvm() {
    unset -f nvm node npm npx
    source "/usr/share/nvm/nvm.sh"
    nvm "$@"
  }
  
  node() {
    unset -f nvm node npm npx
    source "/usr/share/nvm/nvm.sh"
    node "$@"
  }
  
  npm() {
    unset -f nvm node npm npx
    source "/usr/share/nvm/nvm.sh"
    npm "$@"
  }
  
  npx() {
    unset -f nvm node npm npx
    source "/usr/share/nvm/nvm.sh"
    npx "$@"
  }
fi

# ------------------------------------------------------------------------------
#                             COMPLETIONS
# ------------------------------------------------------------------------------
# Optimized completion initialization - only rebuild if needed
autoload -Uz compinit
setopt GLOB_DOTS
local zcompdump="$HOME/.zcompdump"
if [[ $zcompdump(#qNmh+24) ]]; then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi
unset zcompdump

# Load Bun completions.
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Add custom completions directory and source all *.zsh files within it.
ZSH_COMPLETIONS_DIR="$HOME/.config/zsh/completions.d"
if [[ -d "$ZSH_COMPLETIONS_DIR" ]]; then
  fpath=("$ZSH_COMPLETIONS_DIR" $fpath)
  for completion_file in "$ZSH_COMPLETIONS_DIR"/*.zsh(N); do
    source "$completion_file"
  done
fi
unset ZSH_COMPLETIONS_DIR completion_file

# ------------------------------------------------------------------------------
#                                 ALIASES
# ------------------------------------------------------------------------------
# General utilities
alias c='clear'
alias reload='exec zsh'
alias q='exit'
alias open='xdg-open'
alias die='shutdown now'
alias mkdir='mkdir -p'
alias nslookup='dnslookup'
alias ns='nslookup'
alias mkpass='openssl rand -base64 48 | wl-copy'
alias kitty="kitty --start-as=maximized"
[[ "$TERM" = "xterm-kitty" ]] && alias ssh="kitten ssh"

# File and directory listing (using eza)
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first -g'
alias ld='eza -lhD --icons=auto'
alias lt='eza --tree --icons=auto'

# Package management (yay for Arch)
alias up='yay -Syu'
alias un='yay -Rns'
alias pl='yay -Qs'
alias pa='yay -Ss'
alias pc='yay -Sc'
alias po='yay -Qtdq | yay -Rns -'

# Development
alias vc='code'
alias venv='source ./.venv/bin/activate'
alias mariadb='mariadb -uroot'
alias rg='rg --pcre2'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# ------------------------------------------------------------------------------
#                                FUNCTIONS
# ------------------------------------------------------------------------------
# Compile and run a C++ file.
# Usage: crun <filename_without_extension>
crun() {
  g++ -std=c++17 -o "$1.out" "$1.cpp" && ./"$1.out"
}

why() {
  [[ $# -eq 0 ]] && { echo "Usage: why <cmd> [cmd2...]"; return 1;}

  local no_clue=(
    "No clue bruh. Probably some curl | bash malware."
    "Cargo, Go, or manual compile. It's here, but God knows why."
    "Aliens put it there. Or a rogue script."
    "Not pacman, not zsh. It's a mystery."
  )
  
  local not_found=(
    "Ghost in the shell. Not found."
    "Skill issue: binary doesn't exist."
    "404 Executable Not Found."
    "Did you hallucinate that command?"
  )

  local cmd path pkg reason req
  for cmd in "$@"; do
    echo "=> $cmd"
    
    # Check if function or alias
    if whence -w "$cmd" 2>/dev/null | grep -q 'function$'; then
      echo "  Type: Zsh function"
      continue
    elif whence -w "$cmd" 2>/dev/null | grep -q 'alias$'; then
      echo "  Type: Zsh alias -> $(alias "$cmd" | sed "s/^$cmd=//")"
      continue
    fi

    path=$(command -v "$cmd" 2>/dev/null)
    if [[ -z "$path" ]]; then
      echo "  ${not_found[$((RANDOM % ${#not_found[@]} + 1))]}"
      continue
    fi

    echo "  Path: $path"
    
    # Check pacman ownership
    pkg=$(LC_ALL=C pacman -Qo "$path" 2>/dev/null | awk '{print $5}')
    
    if [[ -n "$pkg" ]]; then
      reason=$(LC_ALL=C pacman -Qi "$pkg" | awk -F': ' '/Install Reason/ {print $2}')
      req=$(LC_ALL=C pacman -Qi "$pkg" | awk -F': ' '/Required By/ {print $2}')
      echo "  Pacman package: $pkg"
      echo "  Install reason: $reason"
      [[ "$req" != "None" ]] && echo "  Required by   : $req"
    else
      echo "  ${no_clue[$((RANDOM % ${#no_clue[@]} + 1))]}"
    fi
  done
}

# ------------------------------------------------------------------------------
#                                  THEME
# ------------------------------------------------------------------------------
# Display a random Pokemon because why not?
if command -v pokemon-colorscripts-go >/dev/null 2>&1; then
  pokemon-colorscripts-go --no-title
fi

# Uncomment for profiling: zprof

# bun completions                                                                                                                                                                     │
# [ -s "/home/matdef/.bun/_bun" ] && source "/home/matdef/.bun/_bun" 


# Added by Antigravity CLI installer
export PATH="/home/matdef/.local/bin:$PATH"
