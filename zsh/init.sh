#!/bin/bash
THIS_SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
# PROJECT_PATHなどのsetup時の環境変数の読み込みを行う
source $THIS_SCRIPT_PATH/../setup_env.sh

\cp $THIS_SCRIPT_PATH/.zshrc ~/
\cp $THIS_SCRIPT_PATH/.zprofile ~/
# dein.vimのPluginファイルのコピー
\cp -pr $THIS_SCRIPT_PATH/.zsh/ ~/

exit $?
