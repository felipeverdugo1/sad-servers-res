Scenario: "Alexandria": The Vanishing Backups

Level: Easy

Description: A critical backup cron job has silently stopped working 3 days ago. The backup script is located at /opt/backup/backup.sh and should create daily backups in /var/backups/daily/, but no new backups have been created recently.

Looking at the backup directory, you can see old backup files from a few days ago, proving the system used to work. However, there are no error emails, no obvious error logs, and the cron service appears to be running normally.

Fix ALL issues preventing the backups from running, so that backups are created successfully and reliably.

Test directory: /var/backups/daily/
Backup script: /opt/backup/backup.sh


Test: The solution will be validated by checking if a backup file has been created in the last 10 minutes.

The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 5 minutes.

OS: Debian 13


cron service - reviewTest: The solution will be validated by checking if a backup file has been created in the last 10 minutes.

The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 5 minutes.

OS: Debian 13


cron service - review

systemctl list-units --type=service --state=running


chmod +x service-check.sh


./service-check.sh  cron.service

 Starting Health Check for: cron.service
 Date: Fri Sep  4 16:46:40 UTC 2026
==========================================

[1/4] Checking Systemd Service Status...
✔ Service 'cron.service' is ACTIVE

[2/4] Auto-Detecting Listening Ports...
⚠ Service is running (PID 1471), but no active listening ports were found.

[3/4] Checking Resource Usage...
✔ Main PID: 1471
   CPU Usage: 0.0% | Memory Usage: 1.6%

[4/4] Fetching Recent Logs (Last 5 Error Entries)...
-- No entries --

==========================================
 Health Check Complete
==================================

script que crea los backups diarios
cat /opt/backup/backup.sh 

Deberiamos ver los archivos en esta ruta
ls - la /var/backups/daily/

Y un cat alguno

admin@i-0866e3e49c14825af:~$ cat /opt/backup/backup.sh 
#!/bin/bash
# Backup script for critical data

# FIX: Moved lock file to a persistent location inside /opt/backup
LOCK_FILE="/opt/backup/backup.lock"
BACKUP_DIR="/var/backups/daily"
DATA_DIR="/opt/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"

# Check for lock file
if [ -f "$LOCK_FILE" ]; then
    echo "Error: Backup already running (lock file exists)"
    exit 1
fi

# Create lock file
touch "$LOCK_FILE"

# Perform backup
tar -czf "$BACKUP_FILE" -C "$DATA_DIR" . 2>&1

if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
    # Remove lock file on success
    rm -f "$LOCK_FILE"
    exit 0
else
    echo "Backup failed!"
    rm -f "$LOCK_FILE"
    exit 1
fi

admin@i-0866e3e49c14825af:/var/backups/daily$ tar -xvf backup_20251119_120000.tar.gz 
tar: This does not look like a tar archive

gzip: stdin: unexpected end of file
tar: Child returned status 1
tar: Error is not recoverable: exiting now


tar: Error is not recoverable: exiting now^C
admin@i-0866e3e49c14825af:/opt/backup$ ls -la
total 12
drwxr-xr-x 2 root root 4096 Nov 23  2025 .
drwxr-xr-x 5 root root 4096 Nov 23  2025 ..
-rw-r--r-- 1 root root    0 Nov 23  2025 backup.lock
-rwxr-xr-x 1 root root  722 Nov 23  2025 backup.sh


admin@i-0866e3e49c14825af:/var/backups$ ls -la
total 576
drwxr-xr-x  3 root root   4096 Sep  4 17:46 .
drwxr-xr-x 11 root root   4096 Sep  7  2025 ..
-rw-r--r--  1 root root  40960 Nov 23  2025 alternatives.tar.0
drwxr-xr-x  2 root root   4096 Nov 23  2025 daily
-rw-r--r--  1 root root      0 Sep  4 17:46 dpkg.arch.0
-rw-r--r--  1 root root     32 Nov 23  2025 dpkg.arch.1.gz
-rw-r--r--  1 root root   1416 Aug 14  2025 dpkg.diversions.0
-rw-r--r--  1 root root    294 Aug 14  2025 dpkg.diversions.1.gz
-rw-r--r--  1 root root    146 Nov 23  2025 dpkg.statoverride.0
-rw-r--r--  1 root root     99 Aug 14  2025 dpkg.statoverride.1.gz
-rw-r--r--  1 root root 407610 Nov 23  2025 dpkg.status.0
-rw-r--r--  1 root root 106249 Sep  7  2025 dpkg.status.1.gz



admin@i-0866e3e49c14825af:/var/backups/daily$ ls -la
total 8
drwxr-xr-x 2 root root 4096 Nov 23  2025 .
drwxr-xr-x 3 root root 4096 Sep  4 17:56 ..
-rw-r--r-- 1 root root    0 Nov 17  2025 backup_20251117_120000.tar.gz
-rw-r--r-- 1 root root    0 Nov 18  2025 backup_20251118_120000.tar.gz
-rw-r--r-- 1 root root    0 Nov 19  2025 backup_20251119_120000.tar.gz
admin@i-0866e3e49c14825af:/var/backups/daily$ ^C
admin@i-0866e3e49c14825af:/var/backups/daily$ 

admin@i-0866e3e49c14825af:/opt/backup$ rm -rf backup.lock
rm: cannot remove 'backup.lock': Permission denied
admin@i-0866e3e49c14825af:/opt/backup$ ./backup.sh 
Error: Backup already running (lock file exists)
admin@i-0866e3e49c14825af:/opt/backup$ sudo rm -rf backup.lock
admin@i-0866e3e49c14825af:/opt/backup$ ./backup.sh 

touch: cannot touch '/opt/backup/backup.lock': Permission denied
tar (child): /var/backups/daily/backup_20260904_180808.tar.gz: Cannot open: Permission denied
tar (child): Error is not recoverable: exiting now
tar: /var/backups/daily/backup_20260904_180808.tar.gz: Cannot write: Broken pipe
tar: Child returned status 2
tar: Error is not recoverable: exiting now
Backup failed!


admin@i-0866e3e49c14825af:/opt/backup$ sudo ./backup.sh 
Backup successful: /var/backups/daily/backup_20260904_180857.tar.gz



crontab: installing new crontab
admin@i-0866e3e49c14825af:~$ crontab -e
No modification made
admin@i-0866e3e49c14825af:~$ cd /opt/backup/backup.sh
bash: cd: /opt/backup/backup.sh: Not a directory
admin@i-0866e3e49c14825af:~$ cd /opt/backup
admin@i-0866e3e49c14825af:/opt/backup$ ls
backup.lock  backup.sh
admin@i-0866e3e49c14825af:/opt/backup$ ls -la
total 12
drwxr-xr-x 2 root root 4096 Nov 23  2025 .
drwxr-xr-x 5 root root 4096 Nov 23  2025 ..
-rw-r--r-- 1 root root    0 Nov 23  2025 backup.lock
-rwxr-xr-x 1 root root  722 Nov 23  2025 backup.sh
admin@i-0866e3e49c14825af:/opt/backup$ chmod -x /opt/backup/backup.sh
chmod: changing permissions of '/opt/backup/backup.sh': Operation not permitted
admin@i-0866e3e49c14825af:/opt/backup$ sudo chmod -x /opt/backup/backup.sh
admin@i-0866e3e49c14825af:/opt/backup$ ls -la
total 12
drwxr-xr-x 2 root root 4096 Nov 23  2025 .
drwxr-xr-x 5 root root 4096 Nov 23  2025 ..
-rw-r--r-- 1 root root    0 Nov 23  2025 backup.lock
-rw-r--r-- 1 root root  722 Nov 23  2025 backup.sh
admin@i-0866e3e49c14825af:/opt/backup$ 






Se quedo un archivo lock y este no deja que se sigan creando seguro se rompio algo cuando se estaba ejecutando el script, cree el cron ya que no habia ninguno y lo puse daily

	  GNU nano 8.4                           /tmp/crontab.eNpjx9/crontab                                     
	MAILTO="broken@nonexistent.local"
	# DO NOT EDIT THIS FILE - edit the master and reinstall.
	# (/tmp/crontabhl3tv8j6 installed on Sun Nov 23 18:40:45 2025)
	# (Cron version -- $Id: crontab.c,v 2.13 1994/01/17 03:20:37 vixie Exp $)
	#Ansible: daily backup job
	*/5 * * * * /opt/backup/old_backup.sh > /dev/null 2>&1

	admin@i-0866e3e49c14825af:/etc/cron.daily$ ls -l
	total 20
	-rwxr-xr-x 1 root root 1478 Jun 24  2025 apt-compat
	-rwxr-xr-x 1 root root  123 May 27  2025 dpkg
	-rwxr-xr-x 1 root root 4722 Jun 17  2024 exim4-base
	-rwxr-xr-x 1 root root 1395 May  2  2025 man-db

