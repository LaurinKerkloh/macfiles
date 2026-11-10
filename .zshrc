# I not running interactively, don't do anything
[[ $- != *i* ]] && return

# PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
PATH="$HOME/.local/bin:$PATH"
# PATH="$HOME/go/bin:$PATH"

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Don't beep on errors
unsetopt beep

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[2 q'
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[6 q'
    fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[6 q"
}
zle -N zle-line-init
echo -ne '\e[6 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[6 q' ;} # Use beam shape cursor for each new prompt.

# Edit command line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^v' edit-command-line

# Completion
FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
FPATH="$HOME/.docker/completions:$FPATH"
autoload -Uz compinit
compinit

# Case-insensitive autocomplete
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Autocomplete SSH hosts
zstyle ':completion:*:ssh:*' hosts

# Autocomplete hidden files
setopt globdots

# Special keys
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# More special keys
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history

key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# Don't eat space before pipe when autocompleting
# https://superuser.com/questions/613685/how-stop-zsh-from-eating-space-before-pipe-symbol
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey '^Y' autosuggest-accept

# Syntax highlighting
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# bat
alias cat=bat
# alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- -help='-help 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
export MANPAGER="sh -c 'ansifilter | bat -plman'"

# fzf
source <(fzf --zsh)

# Aliases
alias ls='eza -lh --group-directories-first --icons=auto'

# tmux-sessionizer
tmux-sessionizer-widget() {
    tmux-sessionizer <>$TTY
}
zle -N tmux-sessionizer-widget
bindkey ^f tmux-sessionizer-widget

# mise
eval "$(mise activate zsh)"

# Prompt
eval "$(starship init zsh)"

# Envs
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

# https://github.com/catppuccin/fzf
source $HOME/.local/share/catppuccin-fzf/themes/catppuccin-fzf-mocha.sh

# https://github.com/catppuccin/lazygit
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.local/share/catppuccin-lazygit/themes-mergable/mocha/lavender.yml"

# https://github.com/catppuccin/bat
export BAT_THEME="Catppuccin Mocha"

alias chrome='/Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser'

ng () {
  ~/code/servers/ngserver "$(pwd)" "$@"
}
