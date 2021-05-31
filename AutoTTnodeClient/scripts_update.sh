#!/bin/sh

mergedListFile="/pss/AutoTTnodeClient/merged_list_file.sh"

##甜糖星愿自动收取
function initAutoTTnodeClient() {
    mkdir /AutoTTnodeClient
    cd /AutoTTnodeClient
    git init
    git remote add origin https://gitee.com/watermelon_peel/auto-ttnode-client
    git config core.sparsecheckout true
    echo TTnodeLogin.py >> /AutoTTnodeClient/.git/info/sparse-checkout
    echo AutoTTnodeClient.py >> /AutoTTnodeClient/.git/info/sparse-checkout
    git pull origin master --rebase
    mkdir -p ~/ttnode
    cp -f /AutoTTnodeClient/*.py ~/ttnode
    pip3 install --upgrade pip urllib3
}

if [ ! -d "/AutoTTnodeClient/" ]; then
    echo "未检查到AutoTTnodeClient脚本相关文件，初始化下载相关脚本"
    initAutoTTnodeClient
else
    echo "更新AutoTTnodeClient脚本相关文件"
    git -C /AutoTTnodeClient reset --hard
    git -C /AutoTTnodeClient pull origin master --rebase
    cp -f /AutoTTnodeClient/*.py ~/ttnode
fi
if [ 0"$TTXY_CRON" = "0" ]; then
    TTXY_CRON="0 11 * * *"
fi
echo "#甜糖星愿自动收取">> $mergedListFile
echo "$TTXY_CRON python3 /root/ttnode/AutoTTnodeClient.py >> /logs/AutoTTnodeClient.log 2>&1" >> $mergedListFile
