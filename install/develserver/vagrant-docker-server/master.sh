#!/bin/bash

IRODS_FTP=ftp://ftp.renci.org/pub/irods/releases/4.0.0
PROVISIONED=/home/vagrant/.provisioned

if [ ! -e  $PROVISIONED ]; then
    apt-get update
    apt-get install -q -y curl build-essential python-pip git python-dev postgresql odbc-postgresql unixodbc-dev libssl0.9.8 super

    # install docker
    apt-get install -q -y docker.io
    usermod -a -G docker vagrant
    ln -sf /usr/bin/docker.io /usr/local/bin/docker

    # install irods client
    # this irods package contains the 'irodsFs' utility
	wget -nv $IRODS_FTP/irods-icat-4.0.0-64bit.deb

	dpkg -i *.deb
	apt-get -f install -y

    cp -r /vagrant/.irods  /home/vagrant/.irods

    # mounting irods storage with fuse (for user root)
    # clear text p4ssw0rd here, only for development!
    cp -r /vagrant/.irods  /root/.irods
    sudo iinit rodsgef
    sudo mkdir /data
    sudo irodsFs -o allow_other,ro /data

    # test
    docker run -v /data:/data_1:ro busybox ls -al /data_1

    # Install the gef-docker server
    mkdir /home/vagrant/bin
    cp /vagrant/gef-docker /vagrant/config.json /home/vagrant/bin/

    # done
    chown -R vagrant:vagrant /home/vagrant
    touch $PROVISIONED

    # Start the gef-docker server
    /home/vagrant/bin/gef-docker
fi

# # install java
# add-apt-repository -y ppa:webupd8team/java
# apt-get update
# echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
# apt-get install -y oracle-java8-installer
# export JAVA_OPTS="-Djava.awt.headless=true -Xmx1g"
# export JAVA_HOME=/usr/lib/jvm/java-8-oracle
# ln -s /usr/lib/jvm/java-8-oracle /usr/lib/jvm/default-java