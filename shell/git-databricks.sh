#!/bin/bash -eu

function disp_info () {
  echo -e "\033[1;33m[$1]\033[m $2"
}

realpath --help > /dev/null || ( disp_info "INFO" "realpathが存在しませんでした。coreutilsをインストールしています..." ; brew install coreutils )

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_NAME=$0

CONFIG_FILE=".git-databricks"

WORKSPACE_DEPLOY_PATH="/Projects"

function install_cmd () {
  disp_info "INFO" "$SCRIPT_NAME install"
  

  disp_info "INFO" "databricks cliをインストールしています..."
  pip install databricks-cli 
  
  disp_info "INFO" "databricks configureを実行します...\nhostは https://supership.cloud.databricks.com を入力してください。\ntokenは各自で取得してください。"
  databricks configure --token
  
  disp_info "INFO" "~/.gitignore_globalを有効にしています..."
  git config --global core.excludesfile ~/.gitignore_global
  
  disp_info "INFO" "~/.gitignore_globalに.git_databricksを追記しています..."
  echo -e "\n#git-databricks.sh\n$CONFIG_FILE" >> ~/.gitignore_global
  
  disp_info "INFO" "gitにaliasを設定しています..."
  git config --global alias.databricks "!f() { bash $SCRIPT_PATH \$* ;}; f"
  
  disp_info "INFO" "installが完了しました。\n$ 再起動後、git databricks から実行できます。"
}


function overwrite_to_databricks () {
  GIT_ROOT=`git rev-parse --show-toplevel`
  source $GIT_ROOT/$CONFIG_FILE
  if [ $# -eq 0 ]; then
    databricks workspace import_dir -e -o $GIT_ROOT $WORKSPACE_PATH
  else
    databricks workspace import_dir -e -o $GIT_ROOT $1/`basename $GIT_ROOT`
  fi
}


function overwrite_to_local () {
  GIT_ROOT=`git rev-parse --show-toplevel`
  source $GIT_ROOT/$CONFIG_FILE
  databricks workspace export_dir -o $WORKSPACE_PATH $GIT_ROOT
}


function init_cmd () {
  disp_info "INFO" "$SCRIPT_NAME init"
  
  disp_info "INFO" "git cloneを実行しています..."
  git clone $1 || disp_info "WARNING" "既にディレクトリは存在します."
  
  disp_info "INFO" "ワークスペースにアップロードしています..."
  GIT_REPO_NAME=`basename "$1" | sed -e 's/.git//g'`

  if [[ $2 =~ ^/ ]]; then
    # abs
    WORKSPACE_PATH=$2/$GIT_REPO_NAME
  else
    local USERNAME=`cat ~/.databrickscfg | grep username | awk '{print $3}'`
    WORKSPACE_PATH=/Users/$USERNAME/$2/$GIT_REPO_NAME
  fi

  (cd $GIT_REPO_NAME \
    && (echo WORKSPACE_PATH=$WORKSPACE_PATH > $CONFIG_FILE) \
    && overwrite_to_databricks \
  )
  
  disp_info "INFO" "initが完了しました。"
}


function usage () {
cat <<_EOT_
Usage:
  $0 <command> [<args>]

Commands:
  install                                      このスクリプトをインストールします。まず、databricks-cliをインストールします。次に、~/.gitignore_globalを有効にし.git-databricksを追記します。最後に、~/.bashrcにaliasを追記します。
                                               予めこのスクリプトを適切な場所に移動して下さい。
  init <git_repo_ssh_address> <workspace_path> gitをlocal上にcloneし、指定したworkspaceパスにアップロードします。指定したパスは.git-databricksに保存されます。workspaceパスは絶対パスか、自分のhomeディレクトリからの相対パスが指定可能です。
  pull -o                                      workspaceからlocalへnotebookをダウンロードします。localのスクリプトは強制的に上書きされます。
  push -o                                      localからworkspaceへnotebookをアップロードします。workspaceのスクリプトは強制的に上書きされます。
  deploy -o                                    localからworkspaceのdeployパス $WORKSPACE_DEPLOY_PATH へnotebookをアップロードします。
_EOT_
exit 1
}


###### MAIN ######
case "$1" in
  "install" ) install_cmd ;;
  "init" ) shift; init_cmd $* ;;
  "pull") if [ -z "${2+UNDEF}" ] || [ "$2" != "-o" ];then echo "please $1 -o" ; else overwrite_to_local;fi ;;
  "push") if [ -z "${2+UNDEF}" ] || [ "$2" != "-o" ];then echo "please $1 -o" ; else overwrite_to_databricks;fi ;;
  "deploy") if [ -z "${2+UNDEF}" ] || [ "$2" != "-o" ];then echo "please $1 -o" ; else overwrite_to_databricks $WORKSPACE_DEPLOY_PATH;fi ;;
  "--help") usage;;
  "-h") usage;;
  "*") usage;;
esac

