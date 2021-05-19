#!/bin/sh

if [ -d "/updateTeam/" ]; then
    cd /updateTeam
    echo "更新updateTeam仓库文件..."
    git reset --hard
    git pull origin $updateTeam_BRANCH --rebase
    cp -rf /scripts/shareCodes /updateTeam
    echo "提交updateTeam仓库文件..."
    git add -A
    git commit -m "更新JSON文件"
    git push origin $updateTeam_BRANCH
fi
