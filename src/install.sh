#!/bin/bash
DEBIAN_VERSION=0
function info(){
	echo "========="
	echo $*
	echo "========="
}
function set_locale(){
	info "Sprawdzam i konfiguruje locale"
	grep -q '^pl_PL.UTF-8' /etc/locale.gen

	if [ $? -ne 0 ]
		then
			echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
			locale-gen --purge pl_PL.UTF-8
		else
			echo "Locale ustawione"
	fi
	info Ustawiam locale na pl_PL.UTF-8
	export LC_ALL=pl_PL.UTF-8
}

function get_debian_version(){
  DEBIAN_VERSION=$(cat /etc/issue|tr ' ' '\n'|grep '[0-9]')
}

function set_debian_repos(){
  info "Konfiguruje podstawowe repozytoria"
  if [ "$1" = '' ]
    then
      DV=$DEBIAN_VERSION
    else
      DV=$1
  fi
  case $DV in
    "4.0") echo '
#
# etch
#
deb     http://archive.debian.org/debian-archive/debian     etch main contrib non-free
deb-src http://archive.debian.org/debian-archive/debian     etch main contrib non-free
' > /tmp/$$repo;;
    "5.0") echo '
#
# lenny 
#
deb     http://archive.debian.org/debian-archive/debian     lenny main contrib non-free
deb-src http://archive.debian.org/debian-archive/debian     lenny main contrib non-free
' > /tmp/$$repo;;
    "6.0") echo '
#
# squeeze
#
deb http://ftp.pl.debian.org/debian/ squeeze main contrib non-free
deb-src http://ftp.pl.debian.org/debian/ squeeze main contrib non-free
deb http://security.debian.org/ squeeze/updates main
deb-src http://security.debian.org/ squeeze/updates main
' > /tmp/$$repo;;
	"7") echo '
#
# wheezy
#
deb http://ftp.pl.debian.org/debian/ wheezy main contrib non-free
deb-src http://ftp.pl.debian.org/debian/ wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main
deb-src http://security.debian.org/ wheezy/updates main
# wheezy-updates, previously known as "volatile"
deb http://ftp.pl.debian.org/debian/ wheezy-updates main 
deb-src http://ftp.pl.debian.org/debian/ wheezy-updates main
' > /tmp/$$repo;;
    *) info "Nie wspierana wersja Debiana: $DV"
      return 1;;
  esac
  mv /tmp/$$repo /etc/apt/sources.list
  test -f /etc/apt/preferences && rm /etc/apt/preferences
  test -f /etc/apt/sources.list.d/grml.list && rm /etc/apt/sources.list.d/grml.list
}

function install_postgresql_repos(){
	info "Konfiguruję apt dla postgresql 9.3"
	src/apt.postgresql.org.sh
}

function set_pig_repos(){
	info "Instaluję repozytoria dla pig"
	echo '
deb http://packages.dotdeb.org wheezy-php55 all
deb-src http://packages.dotdeb.org wheezy-php55 all
' > /etc/apt/sources.list.d/pigprint.list
	gpg --keyserver keys.gnupg.net --recv-key 89DF5277
	gpg -a --export 89DF5277 | sudo apt-key add -
	# Postgresql
	install_postgresql_repos
}


set_locale
get_debian_version
set_debian_repos
set_pig_repos

apt-get update
export DEBIAN_FRONTEND=noninteractive
info Instaluje wymagane pakiety
apt-get -t squeeze-backports install git
apt-get install -y nginx redis-server postgresql-9.3

