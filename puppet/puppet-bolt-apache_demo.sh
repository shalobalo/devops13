#!/bin/bash
if ! bolt --version &> /dev/null
then
    echo "'bolt' could not be found. Please install 'bolt'"
    echo "MacOs: 'brew install puppetlabs/puppet/puppet-bolt'"
    exit
fi

if [ ! -f "bolt-project.yaml" ]
then
  bolt project init lab --modules puppetlabs-apache
fi
if [ ! -d modules/profiles/manifests ]
then
  mkdir -p modules/profiles/manifests
fi
if [ ! -d plans ]
then
  mkdir plans
fi

if [ ! -f "modules/profiles/manifests/apache.pp" ]
then
cat << EOF > modules/profiles/manifests/apache.pp
class profiles::apache(
  String \$content      = 'Hello, World!',
  Array[String] \$ports = ['80'],
)
{
  class { 'apache':
    default_vhost => false,
  }

  apache::vhost { 'hello':
    port    => \$ports,
    docroot => '/var/www/html',
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    content => \$content,
  }
}

EOF
fi

if [ ! -f "plans/apache.yaml" ]
then
cat << EOF > plans/apache.yaml
description: Install and configure Apache

parameters:
  targets:
    type: TargetSpec
    description: The targets to configure

steps:
  - description: Install and configure Apache
    name: configure
    targets: \$targets
    resources:
      - class: profiles::apache

return: \$configure
EOF
fi

echo "use: 'bolt plan run lab::apache --run-as root -t <ip_addr> --no-host-key-check --private-key <path_to_priv_key> -u <username>'"

echo "\tExample: 'bolt plan run lab::apache --run-as root --no-host-key-check -t 35.202.48.78 --private-key ~/.ssh/google_compute_engine -u ashalobalo'"