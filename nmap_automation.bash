#! /bin/bash

# Usage:
# 1. Cd into a directory that has the same name as the host name of the machine (host name should be in /etc/hosts)
# 2. Run the script with no arguments
# 3. The script will run a bunch of nmap commands and also generate a To Do list.

rm -f ToDo.txt
machine=$(basename $PWD)

# Full port scan
sudo nmap -vvv -Pn -sS -p- -A -oN $machine.nmap $machine

grep -Po "^\d+(?=/tcp)" ${machine}.nmap > ports.txt
grep -P "^\d+(?=/tcp)" ${machine}.nmap > ports_versions.txt

# FTP
if [[ $(grep -P "^21$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nFTP\n\n\n"
	nmap -vvv -Pn -p 21 -sV --script ftp* -oN ${machine}_ftp.nmap $machine

	echo -e "\nFTP" >> ToDo.txt
	echo "ncrack -f -U ~/passwords/ftp_usernames.txt -P ~/passwords/ftp_passwords.txt --pairwise ftp://$machine" >> ToDo.txt
	echo "hydra -e nsr -t 4 -f -L ~/usernames/qasim.txt -P ~/passwords/rockyou_100.txt ftp://$machine" >> ToDo.txt
	echo "hydra -e nsr -t 4 -f -L usernames.txt -P ~/passwords/rockyou_100.txt ftp://$machine" >> ToDo.txt
fi

# SSH
if [[ $(grep -P "^22$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nSSH\n\n\n"
	nmap -vvv -Pn -p 22 -sV --script ssh2-enum-algos $machine &>> ${machine}_ssh_a.nmap # Retrieve supported algorythms
	nmap -vvv -Pn -p 22 -sV --script ssh-hostkey --script-args="ssh_hostkey=full" $machine &>> ${machine}_ssh_b.nmap # Retrieve weak keys
	nmap -vvv -Pn -p 22 -sV --script ssh-auth-methods --script-args="ssh.user=root" $machine &>> ${machine}_ssh_c.nmap # Check authentication methods

	echo -e "\nSSH" >> ToDo.txt
	echo "ssh-audit $machine 2>&1 | tee $machine.sshaudit" >> ToDo.txt
	echo "ssh-keyscan -t rsa $machine -p 22" >> ToDo.txt
	echo "ncrack -f -U ~/passwords/ssh_usernames.txt -P ~/passwords/ssh_passwords.txt --pairwise ssh://$machine" >> ToDo.txt
	echo "hydra -e nsr -t 4 -v -f -L ~/usernames/qasim.txt -P ~/passwords/rockyou_100.txt ssh://$machine" >> ToDo.txt
	echo "hydra -e nsr -t 4 -v -f -L usernames.txt -P ~/passwords/rockyou_100.txt ssh://$machine" >> ToDo.txt
fi

# Telnet
if [[ $(grep -P "^23$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nTelnet\n\n\n"
	nmap -vvv -Pn -p 23 -sV --script telnet-ntlm-info -oN ${machine}_telnet.nmap $machine
	
	echo -e "\nTelnet" >> ToDo.txt
	echo "ncrack -f -U ~/passwords/telnet_usernames.txt -P ~/passwords/telnet_passwords.txt --pairwise ssh://$machine" >> ToDo.txt
	echo "hydra -e nsr -t 4 -v -f -L ~/usernames/qasim.txt -P ~/passwords/rockyou_100.txt telnet://$machine" >> ToDo.txt
	echo "hydra -e nsr -t 4 -v -f -L usernames.txt -P ~/passwords/rockyou_100.txt telnet://$machine" >> ToDo.txt
fi

# SMTP
if [[ $(grep -P "^25$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nSMTP\n\n\n"
	nmap -vvv -Pn -p 25 -sV --script smtp-* -oN ${machine}_smtp.nmap ${machine}
		
	
	echo -e "\nSMTP" >> ToDo.txt
	echo "nsmtp-user-enum -M VRFY -U /home/kali/usernames/short_combo.txt -t $machine" >> ToDo.txt
	echo "nsmtp-user-enum -M VRFY -U usernames.txt -t $machine" >> ToDo.txt
fi

# SMB (run same command twice and compare results)
if [[ $(grep -P "^139$|^445$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nSMB\n\n\n"
	nmap -vvv -Pn -p 139,445 -sV --script smb-os-discovery,smb-enum-users,smb-enum-shares,smb-vuln-cve-2017-7494,smb-vuln-ms06-025,smb-vuln-ms07-029,smb-vuln-ms08-067,smb-vuln-ms10-054,smb-vuln-ms10-061,smb-vuln-ms17-010 --script-args unsafe=1 -oN ${machine}_smb_1.nmap $machine
	nmap -vvv -Pn -p 139,445 -sV --script smb-os-discovery,smb-enum-users,smb-enum-shares,smb-vuln-cve-2017-7494,smb-vuln-ms06-025,smb-vuln-ms07-029,smb-vuln-ms08-067,smb-vuln-ms10-054,smb-vuln-ms10-061,smb-vuln-ms17-010 --script-args unsafe=1 -oN ${machine}_smb_2.nmap $machine
	
	echo -e "\nSMB" >> ToDo.txt
	echo "hydra -e nsr -t 4 -v -f -L ~/usernames/qasim.txt -P ~/passwords/rockyou_100.txt smb://$machine" >> ToDo.txt
	echo "hydra -e nsr -t 4 -v -f -L usernames.txt -P ~/passwords/rockyou_100.txt smb://$machine" >> ToDo.txt
	echo "enum4linux $machine" >> ToDo.txt
	echo "smbmap -H $machine" >> ToDo.txt
	echo "showmount -e $machine" >> ToDo.txt
fi

# NFS
echo -e "\n\n\n\nNFS\n\n\n"
if [[ $(grep -P "^111$|^2049$" ports.txt | wc -l) -ne 0 ]]; then
	nmap -vvv -Pn -p 111,2049 -sV --script nfs* -oN ${machine}_nfs.nmap $machine

	echo -e "\nNFS" >> ToDo.txt
	echo "showmount -e $machine" >> ToDo.txt
fi

# RPC
if [[ $(grep -P "^111$|^135$|^593$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nRPC\n\n\n"
	nmap -vvv -Pn -p 111,135,593 -sV --script=msrpc-enum,rpc-grind -oN ${machine}_rpc.nmap $machine

	echo -e "\nRPC" >> ToDo.txt
	echo "python3 /home/kali/tools/impacket/examples/rpcdump.py $machine" >> ToDo.txt
fi

# POP3
if [[ $(grep -P "^110$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nPOP3\n\n\n"
	nmap -vvv -Pn -p 110 -sV --script pop3* -oN ${machine}_pop3.nmap $machine
fi

# RDP
if [[ $(grep -P "^3389$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nRDP\n\n\n"
	nmap -vvv -Pn -p 3389 -sV --script rdp* -oN ${machine}_rdp.nmap $machine

	echo -e "\nRDP" >> ToDo.txt
	echo "hydra -e nsr -t 4 -f -L ~/usernames/qasim.txt -P ~/passwords/rockyou_100.txt rdp://$machine" >> ToDo.txt
	echo "hydra -e nsr -t 4 -f -L usernames.txt -P ~/passwords/rockyou_100.txt rdp://$machine" >> ToDo.txt
fi

# MySQL
if [[ $(grep -P "^3306$" ports.txt | wc -l) -ne 0 ]]; then
	echo -e "\n\n\n\nMySQL\n\n\n"
	nmap -vvv -Pn -p 3306 -sV --script mysql-audit,mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-info,mysql-query,mysql-users,mysql-variables,mysql-vuln-cve2012-2122 -oN ${machine}_sql.nmap $machine
fi

# Vulns

ports=$(perl -pe 's/\n/,/g' ports.txt | sed -e 's/,$//g')

echo -e "\n\n\n\nVuln\n\n\n"
sudo nmap -vvv -Pn -sV -p $ports --script vuln -oN ${machine}_vuln.nmap $machine
echo -e "\n\n\n\nVulners\n\n\n"
sudo nmap -vvv -Pn -sV -p $ports --script vulners -oN ${machine}_vulners.nmap $machine
echo -e "\n\n\n\nVulscan\n\n\n"
sudo nmap -vvv -Pn -sV -p $ports --script vulscan/vulscan -oN ${machine}_vulscan.nmap $machine
echo -e "\n\n\n\nVulscan/exploitdb\n\n\n"
sudo nmap -vvv -Pn -sV -p $ports --script vulscan/vulscan --script-args vulscandb=exploitdb.csv -oN ${machine}_vulscan_exploitdb.nmap $machine



# UDP scan takes a LONG time, so run this one LAST
sudo nmap -vvv -Pn -sU -A -T4 -oN ${machine}_udp.nmap $machine
