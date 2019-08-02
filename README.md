# a-key-installation

安装nginx
```bash
bash <(curl -L -s https://raw.githubusercontent.com/jackpanz/a-key-installation/master/centos7-tengine.sh)
```

测试
```bash
openssl version
cat /lib/systemd/system/nginx.service
systemctl start nginx
systemctl status nginx
```

安装jdk8 tomcat9
```bash
bash <(curl -L -s https://raw.githubusercontent.com/jackpanz/a-key-installation/master/centos7-jdk8-tomcat9.sh)
```

测试
```bash
openssl version
cat /lib/systemd/system/nginx.service
systemctl start nginx
systemctl status nginx
```
 
