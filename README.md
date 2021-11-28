Mail-in-a-Box
=============

Mail-in-a-Box helps individuals take back control of their email by defining a one-click, easy-to-deploy SMTP+everything else server: a mail server in a box.

!!! About this fork !!!
-----------------------
This fork of [Mail-in-a-Box](https://github.com/mail-in-a-box/mailinabox) intends to upgrade the base OS to 16.04 LTS and replace Roundcube/Z-push (and more) with the [SOGo Groupware](http://www.sogo.nu/).

As of writing (28th October 2016) this fork is stable and working, and qualifies for production usage.

**NOTE**: There is NO upgrade/migration path from older Mail-in-a-Box installations.

* * *

Our goals are to:

* Make deploying a good mail server easy.
* Promote [decentralization](http://redecentralize.org/), innovation, and privacy on the web.
* Have automated, auditable, and [idempotent](https://sharknet.us/2014/02/01/automated-configuration-management-challenges-with-idempotency/) configuration.
* **Not** make a totally unhackable, NSA-proof server.
* **Not** make something customizable by power users.

Additionally, this project has a [Code of Conduct](CODE_OF_CONDUCT.md), which supersedes the goals above. Please review it when joining our community.

The Box
-------

Mail-in-a-Box turns a fresh Ubuntu 16.04 LTS 64-bit machine into a working mail server by installing and configuring various components.

It is a one-click email appliance. There are no user-configurable setup options. It "just works".

The components installed are:

* SMTP ([postfix](http://www.postfix.org/)), IMAP ([dovecot](http://dovecot.org/))
* Webmail ([SOGo Groupware](http://sogo.nu/))(*), static website hosting ([nginx](http://nginx.org/))
* Calendar and Contact sync ([SOGo Groupware](http://sogo.nu/))*, Fast Text Search ([Solr](http://lucene.apache.org/solr/))
* Spam filtering ([spamassassin](https://spamassassin.apache.org/)), greylisting ([postgrey](http://postgrey.schweikert.ch/)), antivirus ([clamav](https://www.clamav.net/))
* DNS ([nsd4](https://www.nlnetlabs.nl/projects/nsd/)) with [SPF](https://en.wikipedia.org/wiki/Sender_Policy_Framework), DKIM ([OpenDKIM](http://www.opendkim.org/)), [DMARC](https://en.wikipedia.org/wiki/DMARC), [DNSSEC](https://en.wikipedia.org/wiki/DNSSEC), [DANE TLSA](https://en.wikipedia.org/wiki/DNS-based_Authentication_of_Named_Entities), and [SSHFP](https://tools.ietf.org/html/rfc4255) records automatically set
* Backups ([duplicity](http://duplicity.nongnu.org/)), firewall ([ufw](https://launchpad.net/ufw)), intrusion protection ([fail2ban](http://www.fail2ban.org/wiki/index.php/Main_Page)), system monitoring ([munin](http://munin-monitoring.org/))

(*) [SOGo](http://sogo.nu/) provides an seamless experience for these services within the same UI.

It also includes:

* A control panel and API for adding/removing mail users, aliases, custom DNS records, etc. and detailed system monitoring.

For more information on how Mail-in-a-Box handles your privacy, see the [security details page](security.md).

Installation
------------

Start with a completely fresh (really, I mean it) Ubuntu 16.04 LTS 64-bit machine. On the machine...

Clone this repository:

	$ git clone https://github.com/jkaberg/mailinabox-sogo
	$ cd mailinabox

Begin the installation.

	$ sudo setup/start.sh

The Acknowledgements
--------------------
This fork is due to the awesome work done by these [people](https://github.com/jkaberg/mailinabox-sogo/graphs/contributors).

Mail-in-a-Box is similar to [iRedMail](http://www.iredmail.org/) and [Modoboa](https://github.com/tonioo/modoboa).