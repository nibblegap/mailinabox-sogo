#!/bin/bash

source setup/functions.sh

echo "Installing Mail-in-a-Box system management daemon..."

# Install packages.
# flask, yaml, dnspython, and dateutil are all for our Python 3 management daemon itself.
# duplicity does backups. python-pip is so we can 'pip install boto' for Python 2, for duplicity, so it can do backups to AWS S3.
apt_install python3-flask links duplicity libyaml-dev python3-dnspython python3-dateutil python-pip python-dev

# These are required to pip install cryptography.
apt_install build-essential libssl-dev libffi-dev python3-dev

# Install other Python 3 packages used by the management daemon.
# The first line is the packages that Josh maintains himself!
# NOTE: email_validator is repeated in setup/questions.sh, so please keep the versions synced.
hide_output pip3 install --upgrade \
	rtyaml "email_validator>=1.0.0" "free_tls_certificates>=0.1.3" \
	"idna>=2.0.0" "cryptography>=1.0.2" boto psutil

# duplicity uses python 2 so we need to get the python 2 package of boto to have backups to S3.
# boto from the Ubuntu package manager is too out-of-date -- it doesn't support the newer
# S3 api used in some regions, which breaks backups to those regions.  See #627, #653.
hide_output pip install --upgrade boto

# Create an systemd script to start Management daemon
LOCATION=`pwd`
cat > /etc/systemd/system/mailinabox.service << EOF;
[Unit]
Description=Management daemon for Mailinabox

[Service]
Environment=
WorkingDirectory=$LOCATION/management/
ExecStart=/usr/bin/python3 $LOCATION/management/daemon.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload and enable the daemon via systemctl
hide_output systemctl daemon-reload
hide_output systemctl enable mailinabox.service
hide_output systemctl start mailinabox.service

# Create a backup directory and a random key for encrypting backups.
mkdir -p $STORAGE_ROOT/backup
if [ ! -f $STORAGE_ROOT/backup/secret_key.txt ]; then
	$(umask 077; openssl rand -base64 2048 > $STORAGE_ROOT/backup/secret_key.txt)
fi

# Perform nightly tasks at 3am in system time: take a backup, run
# status checks and email the administrator any changes.
cat > /etc/cron.d/mailinabox-nightly << EOF;
# Mail-in-a-Box --- Do not edit / will be overwritten on update.
# Run nightly tasks: backup, status checks.
0 3 * * *	root	(cd `pwd` && management/daily_tasks.sh)
EOF
