#!/bin/bash
# IMAP search with lucene via solr
# --------------------------------
#
# By default dovecot uses its own Squat search index that has awful performance
# on large mailboxes. Dovecot 2.1+ has support for using Lucene internally but
# this didn't make it into the Ubuntu packages, so we use Solr instead to run
# Lucene for us.
#
# Solr runs as a tomcat process. The dovecot solr plugin talks to solr via its
# HTTP interface, causing mail to be indexed when searches occur, and getting
# results back.

source setup/functions.sh # load our functions
source /etc/mailinabox.conf # load global vars

# Install packages and basic configuation
# ---------------------------------------

echo "Installing Solr..."

# Install packages
apt_install solr-tomcat dovecot-solr

# Solr requires a schema to tell it how to index data, this is provided by dovecot
cp /usr/share/dovecot/solr-schema.xml /etc/solr/conf/schema.xml

# Update the dovecot plugin configuration
#
# Break-imap-search makes search work the way users expect, rather than the way
# the IMAP specification expects
tools/editconf.py /etc/dovecot/conf.d/10-mail.conf \
        mail_plugins="$mail_plugins fts fts_solr"

cat > /etc/dovecot/conf.d/90-plugin-fts.conf << EOF;
plugin {
  fts = solr
  fts_autoindex = yes
  fts_solr = break-imap-search url=http://127.0.0.1:8080/solr/
}
EOF

# Bump memory allocation for Solr.
# Not needed? I'll let it sit here for a while.
#echo 'export JAVA_OPTS=-Xms512M -Xmx1024M' > /usr/share/tomcat7/bin/setenv.sh

# Install cronjobs to keep FTS up to date
hide_output install -m 755 conf/cronjob/dovecot /etc/cron.daily/
hide_output install -m 644 conf/cronjob/solr /etc/cron.d/

# PERMISSIONS

# Ensure configuration files are owned by dovecot and not world readable.
chown -R mail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot

# Restart services to reload solr schema & dovecot plugins
restart_service tomcat7
restart_service dovecot