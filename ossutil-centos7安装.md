安装ossutil64
```bash
wget http://gosspublic.alicdn.com/ossutil/1.5.2/ossutil64
chmod 755 ossutil64
mv ossutil64 /usr/local/bin/
```

配置
```bash
./ossutil64 config
```
- config-file:不用输入
- endpoint：oss-cn-hongkong-internal.aliyuncs.com
- accessKeyID：AccessKeyID 
- accessKeySecret：AccessKeySecret
- stsToken:不用输入

上传
```bash
ossutil64 cp -r  ss-go.sh oss://ossname/hongbaodb/
#直接带参数上传
ossutil64 cp -r demo.zip oss://ossname/ -f -e EndPoint -i AccessKeyId -k AccessKeySecret
```
