#!/bin/sh

mergedListFile="/scripts/docker/merged_list_file.sh"

## 添加定时
function addCron() {
    jsnames="$(cd /scripts && ls [a-z]*_*.js)"
    for jsname in $jsnames; do
        if [ $(grep -c "$jsname" "$mergedListFile") -eq '0' ]; then
            if [ "$jsname" == "jd_crazy_joy_coin.js" ]; then
                continue
            else
                jsname_log="$(echo $jsname | cut -d \. -f1)"
                jsname_cn="$(grep "new Env" /scripts/$jsname | awk -F "\(" '{print $2}' | awk -F "\)" '{print $1}' | sed 's:^.\(.*\).$:\1:' | head -1)"
                [[ -z "$jsname_cn" ]] && jsname_cn="$(grep "cron" /scripts/$jsname | grep -oE "/?/?tag\=.*" | cut -d"=" -f2)"
                [[ -z "$jsname_cn" ]] && jsname_cn="$jsname_log"
                if [ -n "$(grep $jsname /scripts/$jsname)" ]; then
                    jscron_name="$jsname"
                else
                    path="$(echo $jsname | awk -F "_" '{print $1}')"
                    jscron_name=${jsname/${path}\_/}
                fi
                jscron="$(
                    perl -ne "{
                        print if /.*([\d\*]*[\*-\/,\d]*[\d\*] ){4,5}[\d\*]*[\*-\/,\d]*[\d\*]( |,|\").*$jscron_name/
                    }" /scripts/$jsname |
                    perl -pe "{
                        s|[^\d\*]*(([\d\*]*[\*-\/,\d]*[\d\*] ){4,5}[\d\*]*[\*-\/,\d]*[\d\*])( \|,\|\").*/?$jscron_name.*|\1|g;
                        s|\*([\d\*])(.*)|\1\2|g;
                        s|  | |g;
                    }" | sort -u | head -1
                )"
                [[ -z "$jscron" ]] && jscron="$(grep "cron:" /scripts/$jsname | awk -F ":" '{print $2}' | xargs)"
                test -n "$jscron" && test -n "$jsname_cn" && echo "# $jsname_cn" >> $mergedListFile
                test -n "$jscron" && echo "$jscron node /scripts/$jsname >> /scripts/logs/$jsname_log.log 2>&1" >> $mergedListFile
                test -n "$jscron" && echo $jsname
            fi
        fi
    done
}

## 克隆Aaron-lv仓库
if [ ! -d "/Aaron-lv/" ]; then
    echo "未检查到Aaron-lv仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/Aaron-lv/JavaScript /Aaron-lv
else
    echo "更新Aaron-lv仓库脚本..."
    git -C /Aaron-lv reset --hard
    git -C /Aaron-lv pull origin master --rebase
fi

## 克隆zooPanda仓库
if [ ! -d "/zooPanda/" ]; then
    echo "未检查到zooPanda仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/zooPanda/zoo /zooPanda
else
    echo "更新zooPanda仓库脚本..."
    git -C /zooPanda reset --hard
    git -C /zooPanda pull origin dev --rebase
fi

## 克隆passerby-b仓库
if [ 0"$JDDJ_COOKIE" != "0" ]; then
    if [ ! -d "/passerby-b/" ]; then
        echo "未检查到passerby-b仓库脚本，初始化下载相关脚本..."
        git clone https://github.com/passerby-b/JDDJ /passerby-b
    else
        echo "更新passerby-b仓库脚本..."
        git -C /passerby-b reset --hard
        git -C /passerby-b pull origin main --rebase
    fi
fi

## 删除运行目录中不在定时文件里的脚本
jsnames="$(cd /scripts && ls [a-z]*_*.js)"
for jsname in $jsnames; do
    if [ $(grep -c "$jsname" "$mergedListFile") -eq '0' ]; then
        if [[ "$jsname" == "jd_speed.js" || "$jsname" == "jd_crazy_joy_coin.js" ]]; then
            continue
        else
            rm -rf /scripts/$jsname
        fi
    fi
done

## 复制Aaron-lv仓库脚本到运行目录
if [ -n "$(ls /Aaron-lv/Task/[a-z]*_*.js)" ]; then
    cp -f /Aaron-lv/Task/[a-z]*_*.js /scripts
fi

## 复制zooPanda仓库脚本到运行目录
if [ -n "$(ls /zooPanda/[a-z]*.js)" ]; then
    for jsname in $(cd /zooPanda && ls [a-z]*.js); do
        cp -f /zooPanda/$jsname /scripts/zooPanda_$jsname
    done
fi

## 删除不运行脚本
if [ -n "$(ls /scripts/[!jA-Z]*_*.js)" ]; then
    js_del="zooPanda_zooBrandcity&jx_cfdtx"
    arr=${js_del//&/ }
    for item in $arr; do
        rm -rf /scripts/$item.js
    done
fi

## wget方式添加脚本
## 京东试用
if [ "$jd_try_ENABLE" = "Y" ]; then
    wget -O /scripts/jd_try.js https://ghproxy.com/https://raw.githubusercontent.com/ZCY01/daily_scripts/main/jd/jd_try.js
fi
## 自定义脚本
for i in `seq 10`; do
    if [ -n "$(eval echo \$Raw$i)" ]; then
        Raws_tmp="$(eval echo \$Raw$i)"
        Raws="$Raws&$Raws_tmp"
    fi
done
if [ -n "$Raws" ]; then
    Raws=${Raws//&/ }
    for Raw in $Raws; do
        re="$(echo $Raw | grep ^https://raw.githubusercontent.com/)"
        js_dir_name="$(echo ${Raw##*/})"
        js_dir_name_grep="$(echo $js_dir_name | grep "_")"
        if [ -z "$js_dir_name_grep" ]; then
            js_dir_url="$(echo $Raw | awk -F"https://" '{print NF-1}')"
            if [ "$js_dir_url" == "1" ]; then
                js_dir_name="$(echo $Raw | cut -d "/" -f4)_$js_dir_name"
            elif [ "$js_dir_url" == "2" ]; then
                js_dir_name="$(echo $Raw | cut -d "/" -f7)_$js_dir_name"
            fi
        fi
        if [ -z "$re" ]; then
            wget -O /scripts/$js_dir_name $Raw
        else
            Raw="$(echo $Raw | sed "s/raw.githubusercontent.com/ghproxy.com\/https:\/\/&/g")"
            wget -O /scripts/$js_dir_name $Raw
        fi
    done
fi

## 添加远程脚本定时
if [ -n "$(ls /scripts/[a-z]*_*.js)" ]; then
    echo "添加远程脚本,脚本列表:"
    addCron
fi

## 复制passerby-b仓库脚本到运行目录并添加定时
if [ -d "/passerby-b/" ]; then
    if [ -n "$(ls /passerby-b/[a-z]*_*.js)" ]; then
        cp -f /passerby-b/[a-z]*_*.js /scripts
        echo -e "\n##############京东到家##############" >> $mergedListFile
        echo "添加passerby-b仓库脚本,脚本列表:"
        addCron
    fi
fi

## 复制挂载脚本到运行目录并添加定时
if [ ! -d "/diy/" ]; then
    echo "未检查到挂载文件夹，请挂载本地文件夹到容器/diy文件夹..."
else
    if [ -n "$(ls /diy/[a-z]*.js)" ]; then
        for jsname in $(cd /diy && ls [a-z]*.js); do
            cp -f /diy/$jsname /scripts/diy_$jsname
        done
        echo -e "\n##############挂载脚本##############" >> $mergedListFile
        echo "添加挂载脚本,脚本列表:"
        addCron
    else
        echo "/diy文件夹为空，请将脚本放入挂载的本地文件夹内..."
    fi
fi
