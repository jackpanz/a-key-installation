# 自动备份mysql

```bash
备份脚步
/data/autobackupmysql.sh
备份文件存放目录
/root/mysql_bk
```

保存以一下命令到autobackupmysql.sh
```bash
filename=`date +%Y%m%d`
#导出备份sql
/usr/bin/mysqldump --default-character-set=utf8mb4 -uroot -p123456 rob-red-packet  >>/root/mysql_bk/${filename}.sql 
#压缩成zip
zip /root/mysql_bk/${filename}.zip /root/mysql_bk/${filename}.sql
#删除sql
rm -f /root/mysql_bk/${filename}.sql
#上传到oss,如果不用只保存到本地
ossutil64 cp -r /root/mysql_bk/${filename}.zip oss://jack-hk-oss/hongbaodb/ -f -e EndPoint -i AccessKeyId -k AccessKeySecret
```

开机启动
```bash
yum -y install vixie-cron crontabs
systemctl start crond

crontab -e
00 03 * * * source /root/autobackupmysql.sh

chkconfig --level 345 crond on
systemctl enable crond
systemctl restart crond
```
