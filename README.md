# a-key-installation

## 安装nginx
```bash
bash <(curl -L -s https://raw.githubusercontent.com/jackpanz/a-key-installation/master/centos7-tengine.sh)
```

测试
```bash
openssl version
cat /lib/systemd/system/nginx.service
systemctl status nginx
```

安装jdk8 tomcat9
```bash
bash <(curl -L -s https://raw.githubusercontent.com/jackpanz/a-key-installation/master/centos7-jdk8-tomcat9.sh)
```

安装后需要重启或source /etc/profile才能生效

测试
```bash
cat /etc/profile
cat /lib/systemd/system/tomcat.service
head /data/soft/tomcat9/bin/catalina.sh -n 120
echo $JAVA_HOME
systemctl status tomcat
```


 
