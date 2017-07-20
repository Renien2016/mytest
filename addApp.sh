#!/bin/bash

[ $# -ne 1 ] && {
echo "Usages:$0 ip" 
exit
}
IP=$1
mysqladmin -ucpms -pcpmsuser -h$IP ping 2>/dev/null |grep alive &>/dev/null  && 
connect_cmd="mysql -ucpms -pcpmsuser -h$IP "
mysqladmin -uoristar -pTickercms3 -h$IP ping 2>/dev/null|grep alive &>/dev/null && 
connect_cmd="mysql -uoristar -pTickercms3 -h$IP "
[[ -z $connect_cmd ]] && {
echo "无法连接$IP 的数据库！！"
exit 0;
}


CI_CODE=`$connect_cmd -e "set names utf8;select CODE,NAME,UID FROM CMS.CI_CINEMA\G" 2>/dev/null|awk -F: '/CODE/{print $2}'|tr -d ' '`
CI_NAME=`$connect_cmd -e "set names utf8;select CODE,NAME,UID FROM CMS.CI_CINEMA\G" 2>/dev/null|awk -F: '/NAME/{print $2}'|tr -d ' '`
CI_UID=`$connect_cmd -e "set names utf8;select CODE,NAME,UID FROM CMS.CI_CINEMA\G" 2>/dev/null|awk -F: '/UID/{print $2}'|tr -d ' '`


mysqladmin -uAPPUSER -papp123456 -h10.2.5.9 ping &>/dev/null || {
echo "无法连接 10.2.5.9 app后台管理数据库";
exit
}

mysql -uAPPUSER -papp123456 -h10.2.5.9 -e "set names utf8;select server_ip,cinema_uid from mp.ice_server_config_info where cinema_code =$CI_CODE\G" 1>.11.txt 2>/dev/null



[[ -z `cat .11.txt` ]] && {

mysql -uAPPUSER -papp123456 -h10.2.5.9 -e "set names utf8;insert into mp.ice_server_config_info(server_ip,server_id,cinema_code,server_name,cinema_uid) values(\"$IP\",$CI_CODE,\"$CI_CODE\",\"$CI_NAME\",\"$CI_UID\")"
} || {

mysql -uAPPUSER -papp123456 -h10.2.5.9 -e "set names utf8;update mp.ice_server_config_info set server_ip=\"$IP\",cinema_uid=\"$CI_UID\" where cinema_code=\"$CI_CODE\""
}
rm -rf .11.txt
echo $CI_CODE $IP $CI_NAME $CI_UID
