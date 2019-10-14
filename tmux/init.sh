#!/bin/bash
THIS_SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
# PROJECT_PATHなどのsetup時の環境変数の読み込みを行う
source $THIS_SCRIPT_PATH/../setup_env.sh

# tmuxが存在するかチェック
if which tmux >/dev/null 2>&1; then
  if [ `os_type` = 'linux' ] \
    || [ `os_type` = "wsl" ]; then
    # tmuxが存在する場合に.tmuxフォルダを作成する
    if [ ! -d "$HOME/.tmux/" ]; then
      mkdir $HOME/.tmux/
    fi

    copy_target="$HOME"
    mkdir -p $copy_target
    # 指定のファイル以外をコピーしてかつ、配下のディレクトリをコピーする
    find $THIS_SCRIPT_PATH -type f -not -name 'init.sh' | while read -r find_path;
    do
      # 本スクリプトのパスをfindで取得したパス文字列から削除する
      relative_path=${find_path##$THIS_SCRIPT_PATH/}
      # コピー先のディレクトリがなければ作成する
      mkdir -p $copy_target/$(dirname $relative_path);
      cp $find_path $copy_target/$relative_path;
    done
  fi
fi

exit $?