#!/bin/sh

function initCdn() {
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
}

function syncRepo() {
    cd /scripts
    echo "设定远程仓库地址..."
    git remote set-url origin $REPO_URL
    echo "git pull拉取最新代码..."
    git reset --hard
    git pull origin $REPO_BRANCH --rebase
    echo "git pull拉取shell最新代码..."
    git -C /jds reset --hard
    git -C /jds pull origin master --rebase
}

#获取配置的自定义参数
if [ "$1" ]; then
    run_cmd=$1
    initCdn
fi

[[ -f "/scripts/package.json" ]] && before_package_json="$(cat /scripts/package.json)"

syncRepo
if [ $? -ne 0 ]; then
    echo "更新仓库代码出错❌，跳过"
else
    echo "更新仓库代码成功✅"
fi

if [ ! -d "/scripts/node_modules" ]; then
    echo "容器首次启动，执行npm install..."
    npm install --loglevel error --prefix /scripts
    if [ $? -ne 0 ]; then
        echo "npm首次启动安装依赖失败❌，exit，restart"
        exit 1
    else
        echo "npm首次启动安装依赖成功✅"
    fi
else
    if [ "$before_package_json" != "$(cat /scripts/package.json)" ]; then
        echo "package.json有更新，执行npm install..."
        npm install --loglevel error --prefix /scripts
        if [ $? -ne 0 ]; then
            echo "package.json有更新，执行安装依赖失败❌，跳过"
            exit 1
        else
            echo "package.json有更新，执行安装依赖成功✅"
        fi
    else
        echo "package.json无变化，跳过npm install..."
    fi
fi

echo "-------------------------------------------------执行定时任务shell脚本--------------------------------------------------"
sh /jds/updateTeam/default_task.sh
if [ $? -ne 0 ]; then
    echo "定时任务shell脚本执行失败❌，exit，restart"
    exit 1
else
    echo "定时任务shell脚本执行成功✅"
fi
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"

if [ -n "$run_cmd" ]; then
    echo "启动crontab定时任务主进程..."
    crond -f
else
    echo "默认定时任务执行结束。"
fi
echo -e "\n\n"
