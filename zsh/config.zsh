if [[ -f ~/.config/posix-sh/config.sh ]]
then emulate sh -c 'source ~/.config/posix-sh/config.sh'
fi

PROMPT='%F{blue}%~%f %(?.%F{green}.%F{red})%#%f '
REPORTTIME=10
WORDCHARS=${WORDCHARS/\/}

bindkey '\e[5~' history-beginning-search-backward # PgUp
bindkey '\e[6~' history-beginning-search-forward # PgDn
bindkey '\e[3~' delete-char # Delete
bindkey '\e[H' beginning-of-line # Home
bindkey '\e[F' end-of-line # End
bindkey -M isearch '\e[5~' history-incremental-search-backward # PgUp
bindkey -M isearch '\e[6~' history-incremental-search-forward # PgDn

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

setopt hist_ignore_dups hist_ignore_space inc_append_history
autoload -Uz add-zsh-hook
source ~/.config/zsh/report-completion.zsh

# For meaning of returning 130, see:
# https://unix.stackexchange.com/questions/99112/default-exit-code-when-process-is-terminated
function ssh() {
	if [[ $# == 1 ]] && [[ -z $SSH_TTY ]]
	then
		function TRAPEXIT() {
			printf '\e]0;\a'
		}
		setopt local_options local_traps
		trap 'return 130' INT

		printf '\e]0;@%s\a' $1
		command ssh $1
	else command ssh $@
	fi
}

# https://unix.stackexchange.com/questions/108699/documentation-on-less-termcap-variables
function () {
	typeset -A mappings=(
		[md]='tput setaf 6' # start of bold: cyan
		[me]='tput sgr0' # end of bold
		[us]='tput setaf 2; tput smul' # start of underline: green underline
		[ue]='tput sgr0' # end of underline
		[so]='tput setaf 0; tput setab 3' # start of standout
		[se]='tput sgr0' # end of standout
	)

	local env_string termcap terminfo
	for termcap terminfo in ${(@kv)mappings}
	do env_string+=$(printf 'LESS_TERMCAP_%s=`%s` ' $termcap $terminfo)
	done
	env_string+='LESS=--LONG-PROMPT'
	alias man="$env_string man"
}

# [deprecated]
function source-maybe() {
	2>/dev/null source $1
}

function source-from-share() {
	2>/dev/null source "/usr/share/$1" ||
		2>/dev/null source "/usr/local/share/$1" ||
		2>/dev/null source "/opt/local/share/$1"
}

function () {
	local ls_alias=$aliases[ls]
	unalias ls
	source-from-share chruby/chruby.sh
	alias ls=$ls_alias
}
if source-from-share chruby/auto.sh
then
	add-zsh-hook -d preexec chruby_auto
	add-zsh-hook precmd chruby_auto
fi

source-from-share nvm/nvm.sh

if 2>/dev/null source /Applications/MacPorts/iTerm2.app/Contents/Resources/iterm2_shell_integration.zsh
then
	function __set-status-bar() {
		iterm2_set_user_var ruby_version ${RUBY_VERSION:-system}
		if command -v nvm > /dev/null
		then iterm2_set_user_var node_version `nvm version`
		fi
	}
	add-zsh-hook precmd __set-status-bar
fi

source-from-share zsh-autosuggestions/zsh-autosuggestions.zsh

function () {
	local preview_command
	if whence -p bat >/dev/null
	then preview_command='bat --style=numbers --color=always --line-range :500 {}'
	else preview_command='cat {}'
	fi
	preview_command="--preview '$preview_command'"

	if source-from-share skim/shell/key-bindings.zsh || # Homebrew, MacPorts, and Fedora
		2>/dev/null source /usr/share/skim/key-bindings.zsh # Arch Linux
	then
		bindkey '^\' skim-cd-widget
		SKIM_CTRL_T_OPTS=$preview_command
	elif source-from-share fzf/shell/key-bindings.zsh ||
		2>/dev/null source /usr/share/fzf/key-bindings.zsh ||
		2>/dev/null source /usr/share/doc/fzf/examples/key-bindings.zsh # Debian
	then
		bindkey '^\' fzf-cd-widget
		FZF_CTRL_T_OPTS=$preview_command
	fi
}

2>/dev/null source ~/.config/zsh/local-config.zsh
source-from-share zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unfunction source-from-share source-maybe
