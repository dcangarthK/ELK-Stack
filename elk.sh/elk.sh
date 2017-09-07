#!/bin/bash
#https://gist.github.com/abhishektomar

# Checking whether user has enough permission to run this script
sudo -n true
if [ $? -ne 0 ]
    then
        echo "This script requires user to have passwordless sudo access"
        exit
fi

dependency_check_deb() {
java -version
if [ $? -ne 0 ]
    then
        # Installing Java 7 if it's not installed
        sudo apt-get install openjdk-7-jre-headless -y
    # Checking if java installed is less than version 7. If yes, installing Java 7. As logstash & Elasticsearch require Java 7 or later.
    elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.7 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
        then
            sudo apt-get install openjdk-7-jre-headless -y
fi
}

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            #Installing Java 7 if it's not installed
            sudo yum install jre-1.7.0-openjdk -y
        # Checking if java installed is less than version 7. If yes, installing Java 7. As logstash & Elasticsearch require Java 7 or later.
        elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.7 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
            then
                sudo yum install jre-1.7.0-openjdk -y
    fi
}

debian_elk() {
    # resynchronize the package index files from their sources.
    sudo apt-get update
    # Downloading debian package of logstash
    sudo wget --directory-prefix=/opt/ https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.1.1-1_all.deb
    # Install logstash debian package
    sudo dpkg -i /opt/logstash_2.1.1-1_all.deb
    # Downloading debian package of elasticsearch
    sudo wget --directory-prefix=/opt/ https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.1.0/elasticsearch-2.1.0.deb
    # Install debian package of elasticsearch
    sudo dpkg -i /opt/elasticsearch-2.1.0.deb
    # Download kibana tarball in /opt
    sudo wget --directory-prefix=/opt/ https://download.elastic.co/kibana/kibana/kibana-4.3.0-linux-x64.tar.gz
    # Extracting kibana tarball
    sudo tar zxf /opt/kibana-4.3.0-linux-x64.tar.gz -C /opt/
    # Starting The Services
    sudo service logstash start
    sudo service elasticsearch start
    sudo /opt/kibana-4.3.0-linux-x64/bin/kibana &
}

rpm_elk() {
    #Installing wget.
    sudo yum install wget -y
    # Downloading rpm package of logstash
    sudo wget --directory-prefix=/opt/ https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.1.1-1.noarch.rpm
    # Install logstash rpm package
    sudo rpm -ivh /opt/logstash-2.1.1-1.noarch.rpm
    # Downloading rpm package of elasticsearch
    sudo wget --directory-prefix=/opt/ https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.1.0/elasticsearch-2.1.0.rpm
    # Install rpm package of elasticsearch
    sudo rpm -ivh /opt/elasticsearch-2.1.0.rpm
    # Download kibana tarball in /opt
    sudo wget --directory-prefix=/opt/ https://download.elastic.co/kibana/kibana/kibana-4.3.0-linux-x64.tar.gz
    # Extracting kibana tarball
    sudo tar zxf /opt/kibana-4.3.0-linux-x64.tar.gz -C /opt/
    # Starting The Services
    sudo service logstash start
    sudo service elasticsearch start
    sudo /opt/kibana-4.3.0-linux-x64/bin/kibana &
}

# Installing ELK Stack
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
    then
        echo " It's a Debian based system"
        dependency_check_deb
        debian_elk
elif [ "$(grep -Ei 'fedora|redhat|centos' /etc/*release)" ]
    then
        echo "It's a RedHat based system."
        dependency_check_rpm
        rpm_elk
else
    echo "This script doesn't support ELK installation on this OS."
fi
