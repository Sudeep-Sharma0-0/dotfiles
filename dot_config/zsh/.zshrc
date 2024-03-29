# Lines configured by zsh-newuser-install
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
setopt HIST_IGNORE_ALL_DUPS       # ignore duplicated commands history list
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=3000
SAVEHIST=3000
# End of lines configured by zsh-newuser-install

colorscript random
echo
# Auto Suggestions
# source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6272a4,bold,underline"
# ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
# bindkey '^ ' autosuggest-accept

# MANGOHUD_CONFIGFILE=~/.config/mangohud/MangoHud.conf
#
#......................Aliases.........................
#

# Changing "ls" to "exa"
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

#Make Executable
alias perms="chmod +x "

# export MPD_HOST="localhost"
# export MPD_PORT="6001"

export _JAVA_AWT_WM_NONREPARTENTING=1
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"
export WINEPREFIX="$XDG_DATA_HOME"/wine

export QT_STYLE_OVERRIDE="gtk3"

export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"

exec fish
