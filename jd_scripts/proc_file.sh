#!/bin/sh

mergedListFile="/scripts/docker/merged_list_file.sh"
shareCodesUrl="https:\/\/ghproxy.com\/https:\/\/raw.githubusercontent.com\/Aaron-lv\/updateTeam\/master\/shareCodes\\"
shareCodesCfd="$shareCodesUrl/cfd.json"
shareCodeszz="$shareCodesUrl/jd_zz.json"
shareCodesZoo="$shareCodesUrl/jd_zoo.json"
shareCodesCash="$shareCodesUrl/jd_updateCash.json"
shareCodesBeanHome="$shareCodesUrl/jd_updateBeanHome.json"
shareCodesFactoryTuanId="$shareCodesUrl/jd_updateFactoryTuanId.json"
shareCodesSmallHomeInviteCode="$shareCodesUrl/jd_updateSmallHomeInviteCode.json"


## 修改京东家庭号定时
sed -i "/jd_family.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_family.js | awk '{print $1,$2,$3,$4,$5}')/30 6,15 * * */g" $mergedListFile
## 修改美丽颜究院定时
sed -i "/jd_beauty.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_beauty.js | awk '{print $1,$2,$3,$4,$5}')/30 8,13,20 * * */g" $mergedListFile
## 修改口袋书店定时
sed -i "/jd_bookshop.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_bookshop.js | awk '{print $1,$2,$3,$4,$5}')/20 8,12,18 * * */g" $mergedListFile
## 修改东东小窝定时
sed -i "/jd_small_home.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_small_home.js | awk '{print $1,$2,$3,$4,$5}')/33 6,23 * * */g" $mergedListFile
## 修改京喜工厂定时
sed -i "/jd_dreamFactory.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_dreamFactory.js | awk '{print $1,$2,$3,$4,$5}')/45 * * * */g" $mergedListFile
## 修改取关京东店铺商品定时
sed -i "/jd_unsubscribe.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_unsubscribe.js | awk '{print $1,$2,$3,$4,$5}')/45 *\/6 * * */g" $mergedListFile
## 修改京东极速版红包定时
sed -i "/jd_speed_redpocke.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_speed_redpocke.js | awk '{print $1,$2,$3,$4,$5}')/15 0,23 * * */g" $mergedListFile

## 清理日志
sed -i "s/find.*$/find \/scripts\/logs -name '\*.log' \| grep -v 'sharecodeCollection' \| xargs -i rm -rf {}/g" $mergedListFile

## 超级直播间
sed -i "/jd_live_redrain.js/s/^.*$/# &/g" $mergedListFile
if [ "$(date +%-H)" == "23" ]; then
   sed -i "/jd_super_redrain.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_super_redrain.js | awk '{print $1,$2,$3,$4,$5}')/0,1 0-23\/1 * * */g" $mergedListFile
fi

## 赚京豆
sed -i "s/await getRandomCode();/\/\/&/g" /scripts/jd_syj.js
sed -i "s/http.*:\/\/.*\.json/$shareCodeszz/g" /scripts/jd_syj.js
## 京喜财富岛
sed -i "s/http.*:\/\/.*\.json/$shareCodesCfd/g" /scripts/jd_cfd.js
## 签到领现金
sed_line="$(sed -n "/const inviteCodes = \[/=" /scripts/jd_cash.js)"
line1=`expr $sed_line + 1`
line2=`expr $sed_line + 2`
sed -i "$line1,$line2 s/^.*$/  \`eU9Yau3kZ_4g-DiByHEQ0A@ZnQya-i1Y_UmpGzUnnEX@fkFwauq3ZA@f0JyJuW7bvQ@IhM0bu-0b_kv8W6E@eU9YKpnxOLhYtQSygTJQ@-oaWtXEHOrT_bNMMVso@eU9YG7XaD4lXsR2krgpG\`,/g" /scripts/jd_cash.js
sed -i "s/http.*:\/\/.*\.json/$shareCodesCash/g" /scripts/jd_cash.js
## 领京豆
sed -i "s/http.*:\/\/.*\.json/$shareCodesBeanHome/g" /scripts/jd_bean_home.js
## 京喜工厂
sed -i "s/http.*:\/\/.*\.json/$shareCodesFactoryTuanId/g" /scripts/jd_dreamFactory.js
## 东东小窝
sed -i "s/http.*:\/\/.*\.json/$shareCodesSmallHomeInviteCode/g" /scripts/jd_small_home.js
## 口袋书店
sed -i "s/'28a699ac78d74aa3b31f7103597f8927@.*$/'6f46a1538969453d9a730ee299f2fc41@3ad242a50e9c4f2d9d2151aee38630b1@1a68165088b345c4ba2d8ce6464fa92b@bf4071c7fcde43828fddb83a08f53d28@abf5065d45e84851b972b37ac205e56a@3d9e58dbf2274db88afa177c7c2dccb0',/g" /scripts/jd_bookshop.js

## 618动物联萌
sed -i "s/http.*:\/\/.*\.json/$shareCodesZoo/g" /scripts/jd_zoo.js
sed -i "s/http:\/\/cdn.trueorfalse.top\/e528ffae31d5407aac83b8c37a4c86bc\//$shareCodesZoo/g" /scripts/jd_zoo.js
