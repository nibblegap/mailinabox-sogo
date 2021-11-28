#!/bin/bash
# This configuration is heavily based upon https://github.com/andryyy/mailcow/blob/master/includes/functions.sh
# aswell as the official SOGo documentation found at https://sogo.nu/files/docs/SOGo%20Installation%20Guide.pdf

source setup/functions.sh # load our functions
source /etc/mailinabox.conf # load global vars


echo "Installing SOGo groupware..."

TIMEZONE=`cat /etc/timezone`
FQDN=`hostname`
DOMAIN=`hostname -d`

hide_output apt-key adv --keyserver keys.gnupg.net --recv-key 0x810273C4
echo "deb http://packages.inverse.ca/SOGo/nightly/3/ubuntu/ xenial xenial" > /etc/apt/sources.list.d/sogo.list
hide_output apt-get update

if [[ -z $(mysql --defaults-file=/etc/mysql/debian.cnf ${MIAB_SQL_DB} -e "SHOW TABLES LIKE 'sogo_view'" -N -B) ]]; then
    mysql --defaults-file=/etc/mysql/debian.cnf ${MIAB_SQL_DB} -e "DROP VIEW IF EXISTS grouped_aliases; DROP VIEW IF EXISTS sogo_view;" -N -B  >> /dev/null
fi

mysql --defaults-file=/etc/mysql/debian.cnf ${MIAB_SQL_DB} -e "CREATE VIEW grouped_aliases (dest, aliases) AS SELECT destination, IFNULL(GROUP_CONCAT(source SEPARATOR ' '), '') AS address FROM miab_aliases WHERE source != destination AND source NOT LIKE '@%' GROUP BY destination;" -N -B  >> /dev/null
mysql --defaults-file=/etc/mysql/debian.cnf ${MIAB_SQL_DB} -e "CREATE VIEW sogo_view (c_uid, c_name, c_password, c_cn, mail, aliases, home) AS SELECT email, email, PASSWORD, name, CONVERT(email USING latin1), IFNULL(ga.aliases, ''), CONCAT('$STORAGE_ROOT/mail/mailboxes/', maildir) FROM miab_users LEFT OUTER JOIN grouped_aliases ga ON ga.dest = miab_users.email WHERE active=1;" -N -B  >> /dev/null

apt_install sogo sogo-activesync libwbxml2-0 memcached

sudo -u sogo bash -c "
defaults write sogod SOGoUserSources '({type = sql;id = directory;viewURL = mysql://mailinabox:${MIAB_SQL_PW}@localhost:3306/${MIAB_SQL_DB}/sogo_view;canAuthenticate = YES;isAddressBook = YES;displayName = \"Global Address Book\";MailFieldNames = (aliases);userPasswordAlgorithm = ssha256;})'
defaults write sogod SOGoProfileURL 'mysql://mailinabox:${MIAB_SQL_PW}@localhost:3306/${SOGO_SQL_DB}/sogo_user_profile'
defaults write sogod OCSFolderInfoURL 'mysql://mailinabox:${MIAB_SQL_PW}@localhost:3306/${SOGO_SQL_DB}/sogo_folder_info'
defaults write sogod OCSEMailAlarmsFolderURL 'mysql://mailinabox:${MIAB_SQL_PW}@localhost:3306/${SOGO_SQL_DB}/sogo_alarms_folder'
defaults write sogod OCSSessionsFolderURL 'mysql://mailinabox:${MIAB_SQL_PW}@localhost:3306/${SOGO_SQL_DB}/sogo_sessions_folder'
defaults write sogod SOGoEnableEMailAlarms YES
defaults write sogod SOGoPageTitle '${FQDN}';
defaults write sogod SOGoForwardEnabled YES;
defaults write sogod SOGoMailAuxiliaryUserAccountsEnabled YES;
defaults write sogod SOGoTimeZone '${TIMEZONE}';
defaults write sogod SOGoMailDomain '${DOMAIN}';
defaults write sogod SOGoAppointmentSendEMailNotifications YES;
defaults write sogod SOGoSieveScriptsEnabled YES;
defaults write sogod SOGoSieveServer 'sieve://127.0.0.1:4190';
defaults write sogod SOGoVacationEnabled YES;
defaults write sogod SOGoDraftsFolderName Drafts;
defaults write sogod SOGoSentFolderName Sent;
defaults write sogod SOGoTrashFolderName Trash;
defaults write sogod SOGoJunkFolderName Spam;
defaults write sogod SOGoMailMessageCheck every_minute;
defaults write sogod SOGoIMAPServer 'imaps://localhost:993';
defaults write sogod SOGoSMTPServer 127.0.0.1;
defaults write sogod SOGoMailingMechanism smtp;
defaults write sogod SOGoForceExternalLoginWithEmail YES;
defaults write sogod SOGoMailCustomFromEnabled YES;
defaults write sogod SOGoPasswordChangeEnabled YES;
defaults write sogod SOGoAppointmentSendEMailNotifications YES;
defaults write sogod SOGoACLsSendEMailNotifications NO;
defaults write sogod SOGoFoldersSendEMailNotifications YES;
defaults write sogod SOGoLanguage English;
defaults write sogod SOGoMemcachedHost '127.0.0.1';
defaults write sogod WOListenQueueSize 300;
defaults write sogod WOWatchDogRequestTimeout 10;
defaults write sogod SOGoMaximumPingInterval 354;
defaults write sogod SOGoMaximumSyncInterval 354;
defaults write sogod SOGoMaximumSyncResponseSize 1024;
defaults write sogod SOGoMaximumSyncWindowSize 15480;
defaults write sogod SOGoInternalSyncInterval 30;
defaults write sogod NGImap4ConnectionStringSeparator '.';"


PREFORK=$(( ($(free -mt | tail -1 | awk '{print $2}') - 100) / 384 * 5 ))
[[ ${PREFORK} -eq 0 ]] && PREFORK="5"
sed -i "/PREFORK/c\PREFORK=${PREFORK}" /etc/default/sogo
sed -i '/SHOWWARNING/c\SHOWWARNING=false' /etc/tmpreaper.conf
sed -i '/expire-autoreply/s/^#//g' /etc/cron.d/sogo
sed -i '/expire-sessions/s/^#//g' /etc/cron.d/sogo
sed -i '/ealarms-notify/s/^#//g' /etc/cron.d/sogo
# doveadm pw -s SSHA256 -p

restart_service sogo