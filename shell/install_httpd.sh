#!/bin/bash
#ssh 34.72.124.158 'bash -s' < install_httpd.sh
debian() {
  if ! dpkg -l|grep -q apache2
  then
    sudo apt -y install apache2
  fi
  if [[ ! -d /var/www/html/ ]]
  then
    mkdir -p /var/www/html/
  fi
  echo "Hello, World!"|sudo tee -a /var/www/html/index.html
  sudo service apache2 restart

  if [[ "$(curl -s localhost)" == 'Hello, World!' ]]
  then
    exit 0
  else 
    exit 1
  fi
}

redhat() {
  if ! yum list installed|grep -q httpd
  then
    sudo yum -y install httpd
  fi
  if [[ ! -d /var/www/html/ ]]
  then
    mkdir -p /var/www/html/
  fi
  echo "Hello, World!"|sudo tee -a /var/www/html/index.html
  sudo service httpd restart

  if [[ "$(curl -s localhost)" == 'Hello, World!' ]]
  then
    exit 0
  else 
    exit 1
  fi
}


if cat /etc/os-release|grep "ID"|grep -q "debian"
then
  debian
elif cat /etc/os-release|grep "ID"|grep -q "centos"
then
  redhat
fi
