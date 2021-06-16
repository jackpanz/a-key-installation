#!/bin/bash
tengineUrl="http://tengine.taobao.org/download/tengine-2.3.3.tar.gz"
tengineversion="tengine-2.3.3"
opensslUrl="https://www.openssl.org/source/openssl-1.1.1k.tar.gz"
opensslversion="openssl-1.1.1k"
tengineDirDef="/usr/local/nginx/"

echo "Enter the tengine installation directory.(default /usr/local/nginx/)"
read tengineDir

if [ -z "$tengineDir" ]
then 
	tengineDir=${tengineDirDef};
fi

echo "Boot automatically tengine?(y/n,default y)"
read tengineAutoStart

if [ -z "$tengineAutoStart" ]
then 
	tengineAutoStart="y";
fi

if [ ${tengineAutoStart} != "y" ] && [ ${tengineAutoStart} != "n" ]
then 
	echo "exit";
	exit 1;
fi

echo "Is ${opensslversion} installed?(y/n,default n)"
read sslInstall

if [ -z "$sslInstall" ]
then 
	sslInstall="n";
fi

if [ ${sslInstall} != "y" ] && [ ${sslInstall} != "n" ]
then 
	echo "exit";
	exit 1;
fi

printf "\033[44;36m%-30s = %s \033[0m\n" "Tengine installation directory" ${tengineDir};
printf "\033[44;36m%-30s = %s \033[0m\n" "Tengine starts automatically" ${tengineAutoStart};
printf "\033[44;36m%-30s = %s \033[0m\n" "TInstall OpenSSL" ${sslInstall};
echo "confirm?(y/n,default n)"
read confirm

if [ -z "$confirm" ] || [ ${confirm} != "y" ]
then 
	echo "exit";
	exit 1;
fi

yum -y install wget gcc gcc-c++ perl-core pcre-devel zlib-devel openssl openssl-devel
mkdir ./workdir
cd workdir

#安装openssl开始
if [ ${sslInstall} = "y" ]
then 
	rm -f ${opensslversion}.tar.gz
	wget ${opensslUrl}
	tar -xzvf ${opensslversion}.tar.gz
	cd ${opensslversion}
	./config --prefix=/usr/local/${opensslversion}
	make && make install

	mv /usr/bin/openssl /usr/bin/openssl.bak
	mv /usr/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1.bak
	mv /usr/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1.bak

	ln -sf /usr/local/${opensslversion}/bin/openssl /usr/bin/openssl
	ln -sf /usr/local/${opensslversion}/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
	ln -sf /usr/local/${opensslversion}/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
	echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
	ldconfig -v
	cd ..
	pwd
fi
#安装openssl结束

#安装nginx开始
rm -f ${tengineversion}.tar.gz
wget ${tengineUrl}
tar -xzvf ${tengineversion}.tar.gz
cd ${tengineversion}
./configure --prefix=${tengineDir} --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_v2_module --with-http_stub_status_module --with-http_ssl_module --add-module=./modules/ngx_http_concat_module
make && make install
cd ..
#安装nginx结束

#nginx开机启动开始
if [ ${tengineAutoStart} = "y" ]
then 
	rm -f nginx.service
	touch nginx.service
	
	echo "[Unit]" >> nginx.service
	echo "Description=The nginx HTTP and reverse proxy server" >> nginx.service
	echo "After=syslog.target network.target remote-fs.target nss-lookup.target" >> nginx.service
	echo "" >> nginx.service
	echo "[Service]" >> nginx.service
	echo "Type=forking" >> nginx.service
	echo "PIDFile=${tengineDir}/logs/nginx.pid" >> nginx.service
	echo "ExecStartPre=${tengineDir}/sbin/nginx -t" >> nginx.service
	echo "ExecStart=${tengineDir}/sbin/nginx -c /data/soft/nginx/conf/nginx.conf" >> nginx.service
	echo "ExecReload=/bin/kill -s HUP \$MAINPID" >> nginx.service
	echo "ExecStop=/bin/kill -s QUIT \$MAINPID" >> nginx.service
	echo "PrivateTmp=true" >> nginx.service
	echo "" >> nginx.service
	echo "[Install]" >> nginx.service
	echo "WantedBy=multi-user.target" >> nginx.service
	mv /lib/systemd/system/nginx.service /lib/systemd/system/nginx.service.bak
	mv ./nginx.service /lib/systemd/system/nginx.service
	chmod a+x /lib/systemd/system/nginx.service
	systemctl enable nginx.service
fi
#nginx开机启动结束
