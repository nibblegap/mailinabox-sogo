#!/bin/bash
source setup/functions.sh # load our functions
source /etc/mailinabox.conf # load global vars

echo "Installing MySQL server..."

apt_install mysql-server

# We need this password for later to auth Dovecot, Postfix and SOGo.
# TODO: This isn't optimal. We should do better... later...
MIAB_SQL_PW=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13`

# Mailinabox database name
MIAB_SQL_DB="mailinabox"
SOGO_SQL_DB="sogo"
MYSQL_DATADIR=$STORAGE_ROOT/mail/mysql/

# Setup the MIAB database, but first check that it doesn't exist already
if [ ! -d $MYSQL_DATADIR ]; then
    # Move the datadir to $STORAGE_ROOT/mail/mysql/ for backup reasons

    # Stop the MySQL daemon as we're editing the config file
    service mysql stop >> /dev/null

    # Change the datadir location for MySQL
    tools/editconf.py /etc/mysql/mysql.conf.d/mysqld.cnf datadir=$MYSQL_DATADIR

    # Create the new database location in our $STORAGE_ROOT
    mkdir -p $MYSQL_DATADIR

    # Move the data
    mv /var/lib/mysql/* $MYSQL_DATADIR

    # Make sure MySQL daemon has proper rights
    chown -R mysql:mysql $MYSQL_DATADIR

    # Make emtpy dir to fool the mysql daemon into thinking these exist
    mkdir -p /var/lib/mysql/mysql

    # Help apparmor detect the new MySQL home and then restart apparmor
    echo "alias /var/lib/mysql/ -> $MYSQL_DATADIR," >> /etc/apparmor.d/tunables/alias
    restart_service apparmor

    # Restart the MySQL daemon
    restart_service mysql

    # Create the MIAB and SOGo database
    mysql --defaults-file=/etc/mysql/debian.cnf -e "CREATE DATABASE ${MIAB_SQL_DB}; CREATE DATABASE ${SOGO_SQL_DB};" >> /dev/null

    # Import our preconfigured database to MySQL
    mysql --defaults-file=/etc/mysql/debian.cnf ${MIAB_SQL_DB} < conf/mailinabox_init.sql >> /dev/null
fi

# Grant privs for mailinabox user so that postfix/dovecot and SOGo can interact with the DB
# Note that the password changes on every install/upgrade
mysql --defaults-file=/etc/mysql/debian.cnf -e "GRANT ALL PRIVILEGES ON ${MIAB_SQL_DB}.* TO 'mailinabox'@'%' IDENTIFIED BY '${MIAB_SQL_PW}'; GRANT ALL PRIVILEGES ON ${SOGO_SQL_DB}.* TO 'mailinabox'@'%' IDENTIFIED BY '${MIAB_SQL_PW}'; FLUSH PRIVILEGES;" >> /dev/null

### TESTING
# Set root password to 1234, and allow connections from anywhere for root user
#mysql --defaults-file=/etc/mysql/debian.cnf -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('1234'); FLUSH PRIVILEGES;" >> /dev/null
#mysql --defaults-file=/etc/mysql/debian.cnf -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'test123';"
#tools/editconf.py /etc/mysql/mysql.conf.d/mysqld.cnf "bind-address=0.0.0.0"
#restart_service mysql
#hide_output ufw allow mysql