#!/bin/bash
mkdir urbem_tmp
cd urbem_tmp
pwd

sudo apt-get update -y

sudo apt-get install -y postgresql-9.1 postgresql-client-9.1 postgresql-contrib-9.1 php5 php5-cli php5-pgsql php5-gd apache2 dialog openjdk-7-jre tomcat7 zip unzip

wget http://www.eclipse.org/downloads/download.php?file=/birt/downloads/drops/R-R1-2_5_0-200906180630/birt-runtime-2_5_0.zip -O birt-runtime-2_5_0.zip

unzip birt-runtime-2_5_0.zip

sudo cp -f -r birt-runtime-2_5_0/WebViewerExample /var/lib/tomcat7/webapps/viewer_250

sudo sed -i '0,/<param-value>true<\/param-value>/{s/<param-value>true<\/param-value>/<param-value>false<\/param-value>/}' /var/lib/tomcat7/webapps/viewer_250/WEB-INF/web.xml

wget http://jdbc.postgresql.org/download/postgresql-9.1-903.jdbc4.jar

sudo cp postgresql-9.1-903.jdbc4.jar /var/lib/tomcat7/webapps/viewer_250/WEB-INF/platform/plugins/org.eclipse.birt.report.data.oda.jdbc_2.5.0.v20090605/drivers

sudo chmod 755 /var/lib/tomcat7/webapps/viewer_250/WEB-INF/platform/plugins/org.eclipse.birt.report.data.oda.jdbc_2.5.0.v20090605/drivers/postgresql-9.1-903.jdbc4.jar


sudo chown -R tomcat7. /var/lib/tomcat7/webapps/viewer_250

sudo service tomcat7 restart


sudo sed -i 's/local   all             all                                     peer/local   all             all                                     md5/g' /etc/postgresql/9.1/main/pg_hba.conf

sudo sed -i 's/port =/port = 2345  #/g' /etc/postgresql/9.1/main/postgresql.conf


sudo service postgresql restart

sudo -u postgres psql template1 << EOF
CREATE EXTENSION hstore;
alter user postgres with password 'nova_senha';
create user urbem superuser password 'nova_senha';
create database urbem;
EOF


sudo wget www.urbem.cnm.org.br/downloads/urbem_2.03.6.sql.bz2

sudo bunzip2 urbem_2.03.6.sql.bz2
sudo -u postgres psql urbem < urbem_2.03.6.sql

sudo -u postgres psql postgres << EOF
alter database urbem owner to urbem;
EOF


wget http://www.urbem.cnm.org.br/versao/03032015-urbem_2.03.6.tar.bz2 -O 03032015-urbem_2.03.6.tar.bz2

tar xjf 03032015-urbem_2.03.6.tar.bz2

sudo cp -r urbem-2.03.6 /var/www/urbem
sudo cp /var/www/urbem/config.yml-dist /var/www/urbem/config.yml

sudo sed -i '0,/port:/{s/port:/port: 2345 #/}' /var/www/urbem/config.yml
sudo sed -i '0,/password:/{s/password:/password: nova_senha #/}' /var/www/urbem/config.yml



sudo sed -i 's/#AddDefaultCharset UTF-8/AddDefaultCharset UTF-8/g' /etc/apache2/conf.d/charset

sudo service apache2 restart


sudo chmod 755 /var/www/urbem
sudo find /var/www/urbem -type d -exec chmod 755 {} \;
sudo find /var/www/urbem -type f -exec chmod 644 {} \;
sudo chmod 400 /var/www/urbem/config.yml 
sudo chmod 777 /var/www/urbem/gestaoAdministrativa/fontes/PHP/framework/tmp
sudo chown -R www-data. /var/www/urbem

