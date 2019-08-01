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

 
