#!/bin/bash
CACHE=/vagrant/cache
ARCH=$(arch)
mkdir -p $CACHE
if [ $ARCH = i686 ]
	then
		ARCH=i386
fi

/bin/ls -1 $CACHE|grep -q "nginx.*$ARCH.deb"
if [ $? -ne 0 ]
	then
		cd /usr/src
		mkdir pagespeed && cd pagespeed
		apt-get -y install dpkg-dev build-essential zlib1g-dev libpcre3 libpcre3-dev
		apt-get -y source nginx
		apt-get -y build-dep nginx
		cd nginx-*
		cd debian/modules
		git clone https://github.com/pagespeed/ngx_pagespeed.git
		cd ngx_pagespeed
		wget https://dl.google.com/dl/page-speed/psol/1.6.29.5.tar.gz
		tar -xzf 1.6.29.5.tar.gz
		cd ../../../
		sed -i 's#$(CONFIGURE_OPTS) >$@#--add-module=$(MODULESDIR)/ngx_pagespeed $(CONFIGURE_OPTS) >$@#' debian/rules
		dpkg-buildpackage -b
		cd /usr/src/pagespeed
		cp nginx-common_1*.deb nginx_1*.deb nginx-full_1*.deb $CACHE
fi
cd $CACHE
dpkg -i nginx-common_1*.deb nginx_1*.deb nginx-full_1*.deb
mkdir /var/ngx_pagespeed_cache
chown -R www-data:www-data /var/ngx_pagespeed_cache

