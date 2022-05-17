#export PATH="$HOME/.local/bin":"$HOME/.emacs.d/bin":"$PATH"
export _JAVA_AWT_WM_NONREPARTENTING=1
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="eastwood"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# DISABLE_LS_COLORS="true"

# DISABLE_AUTO_TITLE="true"

# ENABLE_CORRECTION="true"

# COMPLETION_WAITING_DOTS="true"

# DISABLE_UNTRACKED_FILES_DIRTY="true"

# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='nvim'
fi

colorscript random

#......................Aliases.........................

#Editor
alias ne="nvim"

#Change directory
alias cdco="cd $HOME/.config/"

alias cddo="cd $HOME/Documents/"
alias cddos="cd $HOME/Documents/Self/"
alias cddoc="cd $HOME/Documents/Class-11/Programming-Coding/"


#zsh config
alias zconf="ne $HOME/.config/zsh/.zshrc"

alias nconf="ne $HOME/.config/nvim/init.vim"

#Make Executable
alias perms="chmod +x "

alias code-web="code --extensions-dir ~/.vscode-oss/code_profiles/code-web/extensions --user-data-dir ~/.vscode-oss/code_profiles/code-web/data"

alias nuclear="flatpak run org.js.nuclear.Nuclear"

# Lines configured by zsh-newuser-install
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install

export MPD_HOST="localhost"
export MPD_PORT="6001"
