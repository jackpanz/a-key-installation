## 1.下载相应的tomcat版本
<img src="https://github.com/jackpanz/a-key-installation/blob/master/tomcat-service-create1.png" width="500" /><br/>

## 2.生成window service
#### 用管理员打开cmd,移动到tomcat/bin目录下,输入命令
```bash 
service.bat install Tomcat9Service
```
<img src="https://github.com/jackpanz/a-key-installation/blob/master/tomcat-service-create3.png" width="600" /><br/>

## 3.生成tomcat gui文件
#### 在tomcat/bin目录下有个tomcat9w.exe文件，复制一份重名成Tomcat9Servicew.exe
tomcat9w.exe是启动tomcat gui的，而绑定的服务名就是自身的文件名+w，所以重名成服务名+w.exe

<img src="https://github.com/jackpanz/a-key-installation/blob/master/tomcat-service-create4.png" width="800" /><br/>
