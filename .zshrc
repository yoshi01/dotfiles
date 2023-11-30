# zsh {{{1

# 環境変数
export LANG=ja_JP.UTF-8

export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin

# 色を使用出来るようにする
autoload -Uz colors
colors

# emacs 風キーバインドにする
bindkey -e

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# プロンプト {{{2
# vcs_info
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "+"
zstyle ':vcs_info:git:*' unstagedstr "*"
zstyle ':vcs_info:*' formats "%F{yellow}(%b%u%c)%f"
zstyle ':vcs_info:*' actionformats '(%b|%a)'
precmd () { vcs_info }
PROMPT="%{${fg[cyan]}%}%~%{${reset_color}%} "
PROMPT=$PROMPT'${vcs_info_msg_0_}'
PROMPT=$PROMPT"
%{${fg[cyan]}%}%#%{${reset_color}%} "

# }}}

# 補完 {{{2
# 補完機能を有効にする
autoload -Uz compinit
compinit

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# }}}

# オプション {{{2
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# フローコントロールを無効にする
setopt no_flow_control

# Ctrl+Dでzshを終了しない
setopt ignore_eof

# '#' 以降をコメントとして扱う
setopt interactive_comments

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 高機能なワイルドカード展開を使用する
setopt extended_glob

# }}}

# zplug {{{2
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

# plugins
# zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

# }}}

# }}}

# tmux {{{1
# Created by newuser for 5.6.2
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num/Enter) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" == '' ]]; then
             echo tmux killed..
             return 0
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}
tmux_automatically_attach_session

# }}}

# Setup ssh-agent {{{1
if [ -f ~/.ssh-agent ]; then
  . ~/.ssh-agent
fi
if [ -z “$SSH_AGENT_PID” ] || ! kill -0 $SSH_AGENT_PID; then
  ssh-agent > ~/.ssh-agent
  . ~/.ssh-agent
fi
ssh-add -l >& /dev/null || ssh-add -K ~/.ssh/github_rsa

# }}}

# function {{{1

# cd {{{2

function cdl {
    local -a dirlist opt_f=false
    local i d num=0 dirnum opt opt_f
    while getopts ":f" opt ; do
        case $opt in
            f ) opt_f=true ;;
        esac
    done
    shift $(( OPTIND -1 ))
    dirlist[0]=..
    for d in * ; do test -d "$d" && dirlist[$((++num))]="$d" ; done
    for i in $( seq 0 $num ) ; do printf "%3d %s%b\n" $i "$( $opt_f && echo -n "$PWD/" )${dirlist[$i]}" ; done
    read -p "select number: " dirnum
    if [ -z "$dirnum" ] ; then
        echo "$FUNCNAME: Abort." 1>&2
    elif ( echo $dirnum | egrep '^[[:digit:]]+$' > /dev/null ) ; then
        cd "${dirlist[$dirnum]}"
    else
        echo "$FUNCNAME: Something wrong." 1>&2
    fi
}

cdf ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

cdls ()
{
    \cdf "$@" && ls -G
}

csvless ()
{
    # column -s, -t < $@ | less -#2 -N -S
    column -s, -t < $@ | less -N -S
}

function cd_find() {
    cd "$(find . -type d | peco)"
}

# }}}

# peco {{{2

function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection

# agで検索した結果から選択し、ファイルを開く
function agg(){
  vim $(ag $@ | peco --query "$LBUFFER" | awk -F : '{print "-c " $2 " " $1}')
}

function peco-file() {
    local filepath=$(ag -l | peco --prompt 'PATH >')
    if [ -n "$filepath" ]; then
        if [ -n "$BUFFER" ]; then
            BUFFER="$BUFFER $(echo $filepath | tr '\n' ' ')"
            CURSOR=$#BUFFER
        else
            if [ -f "$filepath" ]; then
                BUFFER="vim $filepath"
                zle accept-line
            fi
        fi
    fi
}
zle -N peco-file
bindkey '^f' peco-file

function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

# }}}

function csvjoin() {
    `awk 'NR==1 || FNR!=1' *.csv > $1.csv`
}

# }}}

#alias {{{1

export LSCOLORS=gxfxcxdxbxegedabagacad

alias cd="cdls"
alias lcsv="csvless"
alias qcsv="q -d ',' -bH"
alias cf="cd_find"
alias ls='ls -G'
alias la='ls -a -G'
alias ll='ls -al -G'
alias f='open .'
alias cl='clear'
alias sc='source'
alias bashup='source ~/.bashrc'

alias vs='code .'
alias p='pstorm .'
alias v='vim'
alias tags='ctags -R -f .tags'
alias ctags="`brew --prefix`/bin/ctags"
alias t='tig'
alias g='git'

alias tmk='tmux kill-server'
alias pshfs='ps aux | grep sshfs'
alias kq='kill -9'
alias mtvag='sshfs vagrant@192.168.33.10:/home/vagrant mount'
alias umt='umount -f mount/'
alias vag='vagrant'



# git {{{2
alias gst='git status; git diff'
alias gss='git stash; git stash apply stash@{0}'
alias gcl='git pull origin master; git fetch -p'
alias gpl='git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gco='git checkout `git branch -a | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'
# alias gcp='git checkout `git --no-pager reflog | awk '\$3 == "checkout:" && /moving from/ {print \$8}' | uniq | head | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'


function grb(){
    git rebase -i HEAD~$@
}

# }}}

# Rails {{{2
alias rs='rails s'
alias rs0='rails s -b 0.0.0.0'
alias rc='rails c'
alias rr='rake routes'
alias be='bundle exec'
alias bi='bundle install'

# }}}


# }}}

# vim: foldmethod=marker
# vim: foldcolumn=3
# vim: foldlevel=0
