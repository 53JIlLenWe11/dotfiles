#---------------------------------------------------------------
# ディレクトリやファイルに設定された色をチェックするための関数
#---------------------------------------------------------------
ls_color_check(){
  typeset -A names
    names[no]="global default"
    names[fi]="normal file"
    names[di]="directory"
    names[ln]="symbolic link"
    names[pi]="named pipe"
    names[so]="socket"
    names[do]="door"
    names[bd]="block device"
    names[cd]="character device"
    names[or]="orphan symlink"
    names[mi]="missing file"
    names[su]="set uid"
    names[sg]="set gid"
    names[tw]="sticky other writable"
    names[ow]="other writable"
    names[st]="sticky"
    names[ex]="executable"

    for i in ${(s.:.)LS_COLORS}
  do
    key=${i%\=*}
  color=${i#*\=}
  name=${names[(e)$key]-$key}
  printf '\e[%sm%s\e[m\n' $color $name
    done
}

#---------------------------------------------------------------
# 特定のある列だけを取り出す col 2 これで2列目を取り出す 例)git statu -s | col 2
#---------------------------------------------------------------
function col {
  awk -v col=$1 '{print $col}'
}

#---------------------------------------------------------------
# 取り出した結果の最初はタイトル行だから不要飛ばす 例)docker rmi $(docker images | col 3 | xargs | skip 1)
#---------------------------------------------------------------
function skip {
    n=$(($1 + 1))
    cut -d' ' -f$n-
}

#---------------------------------------------------------------
# mkdirとcdを同時実行
#---------------------------------------------------------------
function mkcd {
  if [[ -d $1 ]]; then
    echo "$1 already exists!"
    cd $1
  else
    mkdir -p $1 && cd $1
  fi
}

#---------------------------------------------------------------
# cd後にls実行時に10行より多い場合は、前後5行づつ表示する
#---------------------------------------------------------------
ls_abbrev(){
  if [[ ! -r $PWD ]]; then
    return
  fi
  # -a : Do not ignore entries starting with ..
  # -C : Force multi-column output.
  # -F : Append indicator (one of */=>@|) to entries.
  local cmd_ls='ls'
  local -a opt_ls
  opt_ls=('-AXCFv' '--group-directories-first' '--color=always')
  case "${OSTYPE}" in
    freebsd*|darwin*)
      if type gls > /dev/null 2>&1; then
        cmd_ls='gls'
      else
        # -G : Enable colorized output.
        opt_ls=('-aCFG')
      fi
      ;;
  esac

  local ls_result
  ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

  local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

  if [ $ls_lines -gt 10 ]; then
    echo "$ls_result" | head -n 5
    echo ' ︙'
    echo ' ︙'
    echo "$ls_result" | tail -n 5
    echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
  else
    echo "$ls_result"
  fi
}

#---------------------------------------------------------------
# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
#---------------------------------------------------------------
fkill() {
  local pid
  if [ "$UID" != "0"  ]; then
    pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
  else
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  fi

  if [ "x$pid" != "x"  ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}
#---------------------------------------------------------------
# fd - cd to selected directory
#---------------------------------------------------------------
fd() {
  local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune \
        -o -type d -print 2> /dev/null | fzf +m) &&
    cd "$dir"
}

#---------------------------------------------------------------
# fda - including hidden directories
#---------------------------------------------------------------
fda() {
  local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}
#---------------------------------------------------------------
# tm - create new tmux session, or switch to existing one. Works from within tmux too. (@bag-man)
# `tm` will allow you to select your tmux session via fzf.
# `tm irc` will attach to the irc session (if it exists), else it will create it.
#---------------------------------------------------------------
tm() {
  [[ -n "$TMUX"  ]] && change="switch-client" || change="attach-session"
    if [ $1  ]; then
      tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
        fi
        session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

#---------------------------------------------------------------
# fshow - git commit browser
#---------------------------------------------------------------
flog() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
      (grep -o '[a-f0-9]\{7\}' | head -1 |
       xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
      {}
FZF-EOF"
}


#---------------------------------------------------------------
# Select a docker container to start and attach to
#---------------------------------------------------------------
function dattach() {
  local cid
    cid=$(docker ps -a | sed 1d | fzf -1 -q "$1" | awk '{print $1}')

    [ -n "$cid"  ] && docker start "$cid" && docker attach "$cid"
}

#---------------------------------------------------------------
# Select a running docker container to stop
#---------------------------------------------------------------
function dstop() {
  local cid
    cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')

    [ -n "$cid"  ] && docker stop "$cid"
}

