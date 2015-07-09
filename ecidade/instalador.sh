#!/bin/bash
sudo apt-get install python-software-properties 
sudo apt-add-repository ppa:pitti/postgresql -y

echo config postgresql

sudo apt-get update
sudo apt-get install -y postgresql-9.2 postgresql-contrib-9.2 

sudo pg_dropcluster --stop 9.2 main

sudo sed -i '/END LC_IDENTIFICATION/,/END LC_COLLATE/c\END LC_IDENTIFICATION\nLC_COLLATE\ncopy "iso14651_t1"\n\nreorder-after <U00A0>\n<U0020><CAP>;<CAP>;<CAP>;<U0020>\nreorder-end\n\nEND LC_COLLATE'  /usr/share/i18n/locales/pt_BR

sudo localedef -i pt_BR -c -f ISO-8859-1 -A /usr/share/locale/locale.alias pt_BR 
sudo locale-gen pt_BR 
sudo dpkg-reconfigure locales 

export LC_ALL=pt_BR
sudo echo LC_ALL=pt_BR >> /etc/environment


sudo pg_createcluster -e LATIN1 9.2 main
sudo /etc/init.d/postgresql start

sudo sed -i 's/all                                     peer/all                                     trust/g' /etc/postgresql/9.2/main/pg_hba.conf


sudo sed -i 's/md5/trust/g' /etc/postgresql/9.2/main/pg_hba.conf

sudo /etc/init.d/postgresql reload


sudo sed -i "s,listen_addresses =,\nlisten_addresses = '*'  #,g" /etc/postgresql/9.2/main/postgresql.conf
sudo sed -i 's/max_connections =/\nmax_connections = 20  #/g'  /etc/postgresql/9.2/main/postgresql.conf

sudo sed -i "s,bytea_output =,\nbytea_output = 'escape' #,g" /etc/postgresql/9.2/main/postgresql.conf

sudo sed -i 's/max_locks_per_transaction =/\nmax_locks_per_transaction = 256 #/g'  /etc/postgresql/9.2/main/postgresql.conf
sudo sed -i 's/default_with_oids =/\ndefault_with_oids = on #/g'  /etc/postgresql/9.2/main/postgresql.conf


sudo sed -i 's/escape_string_warning =/\nescape_string_warning = off #/g'  /etc/postgresql/9.2/main/postgresql.conf

sudo sed -i 's/standard_conforming_strings =/\nstandard_conforming_strings = off #/g'  /etc/postgresql/9.2/main/postgresql.conf


sudo /etc/init.d/postgresql restart

echo install apache2

sudo apt-get install -y apache2 
echo config apache2

sudo rm /etc/apache2/apache2.conf
wget https://s3-us-west-2.amazonaws.com/projeto-redes-digitais/apache2.conf
sudo cp apache2.conf /etc/apache2/


sudo sed -i "\$aAddDefaultCharset ISO-8859-1" /etc/apache2/conf.d/charset

sudo mkdir /var/www/tmp
sudo chown -R www-data.www-data /var/www/tmp
sudo chmod -R 777 /var/www/tmp

echo install php5
sudo apt-get install -y php5 php5-gd php5-pgsql php5-cli php5-mhash php5-mcrypt

sudo mkdir /var/www/log
sudo chown -R www-data.www-data /var/www/log
sudo chown root.www-data /var/lib/php5
sudo chmod g+r /var/lib/php5

sudo rm /etc/php5/apache2/php.ini
wget https://s3-us-west-2.amazonaws.com/projeto-redes-digitais/php.ini
sudo cp php.ini /etc/php5/apache2/
 	
sudo /etc/init.d/apache2 restart

sudo apt-get install -y libreoffice-writer python-uno openjdk-6-jre	 	 	

sudo awk '/exit 0/{c++;if(c==2){sub("exit 0","/usr/bin/soffice -accept=\"socket,host=localhost,port=8100;urp;\" -nofirststartwizard -headless \\& \nexit0");c=0}}1'  /etc/rc.local > rc.local

sudo cp rc.local /etc

	 	 	
sudo useradd -d /home/dbseller -g www-data -k /etc/skel -m -s /bin/bash dbseller
sudo echo "dbseller:dbseller" | chpasswd

sudo sed -i 's/UMASK/UMASK    002\n #/g' /etc/login.defs

	 	 	
cd /tmp

sudo wget https://s3-us-west-2.amazonaws.com/projeto-redes-digitais/e-cidade-2.3.29-linux.completo.tar.bz2 	
 	 	
sudo tar jxvf e-cidade-2.3.29-linux.completo.tar.bz2


sudo cp -r /tmp/e-cidade-2.3.29-linux.completo/e-cidade /var/www/

sudo chown -R dbseller.www-data /var/www/e-cidade
sudo chmod -R 775 /var/www/e-cidade
sudo chmod -R 777 /var/www/e-cidade/tmp



sudo sed -i 's/$DB_USUARIO/$DB_USUARIO = '\''ecidade'\''; \/\//g' /var/www/e-cidade/libs/db_conn.php

sudo sed -i 's/$DB_SENHA/$DB_SENHA = '\''ecidade'\''; \/\//g' /var/www/e-cidade/libs/db_conn.php

sudo sed -i 's/$DB_SERVIDOR /$DB_SERVIDOR = '\''localhost'\''; \/\//g' /var/www/e-cidade/libs/db_conn.php


sudo sed -i 's/$DB_PORTA /$DB_PORTA = '\''5432'\''; \/\//g' /var/www/e-cidade/libs/db_conn.php


sudo sed -i 's/$DB_PORTA_ALT /$DB_PORTA_ALT = '\''5432'\''; \/\//g' /var/www/e-cidade/libs/db_conn.php

sudo sed -i 's/$DB_BASE /$DB_BASE = '\''ecidade'\''; \/\//g' /var/www/e-cidade/libs/db_conn.php






cd /tmp/e-cidade-2.3.29-linux.completo/sql

sudo psql -U postgres -h localhost template1 -c  "CREATE ROLE ecidade WITH SUPERUSER LOGIN PASSWORD 'ecidade'"

sudo psql -U postgres -h localhost template1 -c "CREATE ROLE dbseller WITH LOGIN PASSWORD 'dbseller'"

sudo psql -U postgres -h localhost template1 -c  "CREATE ROLE plugin WITH LOGIN PASSWORD 'plugin'"

sudo psql -U postgres -h localhost template1 -c "CREATE DATABASE ecidade OWNER ecidade"
sudo psql -U ecidade -h localhost template1 -d ecidade -f e-cidade-2.3.29.sql 2> /tmp/erros.txt

sudo psql -U ecidade -h localhost template1 -d ecidade -c "VACUUM ANALYZE VERBOSE"




