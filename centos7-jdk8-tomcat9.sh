#!/bin/bash
tomcatInstall="n"
tomcatUrl="https://jack-hk-oss.oss-cn-hongkong.aliyuncs.com/apache-tomcat-9.0.27.tar.gz"
#tomcatUrl="http://192.168.56.1/apache-tomcat-9.0.22.tar.gz"
tomcatName="apache-tomcat-9.0.27"
tomcatDir="/usr/local/tomcat9"
#tomcatDir="/data/soft/tomcat9"
tomcatAuto="n"

jdkInstall="n"
jdkUrl="https://jack-hk-oss.oss-cn-hongkong.aliyuncs.com/jdk1.8.0_161.tar.gz"
#jdkUrl="http://192.168.56.1/jdk1.8.0_161.tar.gz"
jdkName="jdk1.8.0_161"
jdkDir="/usr/local/jdk8"
#jdkDir="/data/soft/jdk8"


echo "Is JDK8 installed?(y/n,default n)"
read jdkInstall

if [ -z "$jdkInstall" ] || [ ${jdkInstall} != "y" ]; then 
	jdkInstall="n"
else
	echo "Enter the jdk8 installation directory.(default ${jdkDir})"
	read jdkDirTemp
	if [ -n "$jdkDirTemp" ]; then 
		jdkDir=${jdkDirTemp};
	fi
	
	if [ ${jdkDir: -1} = "/" ]; then
		jdkDir=${jdkDir%?}
	fi
fi

echo "Is Tomcat installed?(y/n,default n)"
read tomcatInstall

if [ -z "$tomcatInstall" ] || [ ${tomcatInstall} != "y" ]; then 
	tomcatInstall="n"
else
	echo "Enter the tomcat9 installation directory.(default ${tomcatDir})"
	read tomcatDirTemp
	if [ -n "$tomcatDirTemp" ]; then 
		tomcatDir=${tomcatDirTemp};
	fi
	
	if [ ${tomcatDir: -1} = "/" ]; then
		tomcatDir=${tomcatDir%?}
	fi

	echo "Boot automatically tomcat?(y/n,default n)"
	read tomcatAuto
	if [ ${tomcatAuto} != "y" ]; then
		tomcatAuto="n"
	fi
fi

printf "\033[44;36m%-30s = %s \033[0m\n" "Install JDK8" ${jdkInstall};
printf "\033[44;36m%-30s = %s \033[0m\n" "JDK8 installation directory" ${jdkDir};
printf "\033[44;36m%-30s = %s \033[0m\n" "Install tomcat9" ${tomcatInstall};
printf "\033[44;36m%-30s = %s \033[0m\n" "Tomcat installation directory" ${tomcatDir};
printf "\033[44;36m%-30s = %s \033[0m\n" "Tomcat starts automatically" ${tomcatAuto};

echo "confirm?(y/n,default n)"
read confirm
if [ -z "$confirm" ] || [ ${confirm} != "y" ]; then
	echo "exit";
	exit 1;
fi

yum install rng-tools -y
systemctl enable rngd
systemctl start rngd

if [ ! -d "./workdir" ]; then
mkdir ./workdir
fi
cd workdir

#安装jdk8开始
if [ ${jdkInstall} = "y" ]; then
	rm -f ${jdkName}.tar.gz
	wget ${jdkUrl}
	jdkDirSub=${jdkDir##*/}
	jdkDirParent=${jdkDir%/*}
	tar -xzf ${jdkName}.tar.gz
	mv ${jdkDir} ${jdkDir}_bak
	mkdir -p ${jdkDirParent}
	mv ${jdkName} ${jdkDir}
	
	echo "export JAVA_HOME=${jdkDir}" >> /etc/profile
	echo "export JRE_HOME=${jdkDir}/jre" >> /etc/profile
	echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib" >> /etc/profile

	echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile
	echo "export JAVA_HOME CLASSPATH PATH JRE_HOME" >> /etc/profile
	source /etc/profile
	cd ..
fi
#安装jdk8结束

#安装tomcat开始
if [ ${tomcatInstall} = "y" ]; then
	rm -f ${tomcatName}.tar.gz
	wget ${tomcatUrl}
	tomcatDirSub=${tomcatDir##*/}
	tomcatDirParent=${tomcatDir%/*}
	tar -xzf ${tomcatName}.tar.gz
	mv ${tomcatDir} ${tomcatDir}_bak
	mkdir -p ${tomcatDirParent}
	mv ${tomcatName} ${tomcatDir}
	
	cd ..
fi
#安装tomcat结束

#tomcat开机启动开始
if [ ${tomcatInstall} = "y" ]
then 
	sed -i "110i JAVA_HOME=${jdkDir}\nJRE_HOME=\$JAVA_HOME/jre" ${tomcatDir}/bin/catalina.sh;

	rm -f tomcat.service
	touch tomcat.service
	
	echo "[Unit]" >> tomcat.service
	echo "Description=Tomcat" >> tomcat.service
	echo "After=network.target" >> tomcat.service
    echo "" >> tomcat.service
	echo "[Service]" >> tomcat.service
	echo "Type=oneshot" >> tomcat.service
	echo "ExecStart=${tomcatDir}/bin/startup.sh" >> tomcat.service
	echo "ExecStop=${tomcatDir}/bin/shutdown.sh" >> tomcat.service
	echo "ExecReload=/bin/kill -s HUP \$MAINPID" >> tomcat.service
	echo "RemainAfterExit=yes" >> tomcat.service
	echo "" >> tomcat.service
	echo "[Install]" >> tomcat.service
	echo "WantedBy=multi-user.target" >> tomcat.service
	
	mv /lib/systemd/system/tomcat.service /lib/systemd/system/tomcat.service.bak
	mv ./tomcat.service /lib/systemd/system/tomcat.service
	chmod a+x /lib/systemd/system/tomcat.service
	systemctl enable tomcat.service
fi
#tomcat开机启动结束




