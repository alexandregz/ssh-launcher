#!/bin/bash
#
# lanza ssh contra o que estea no clipboard, engadindo sufixos necesarios
# por exemplo se temos o host "vostok.local" pero só copiamos ao clipboard "vostok"
#

SUFFIX_LAN=".local"

# lanzamos em tab de terminator como root
launch_ssh() {
	terminator --new-tab -x 'ssh -l root '$1
	exit
}

# comando host para comprobar
checkHost() {
	host $1 2>&1 >/dev/null
	retVal=$?
}

# zenity para amosar erros
errorZenity() {
	zenity --error --text "Nom se puido resolver \n\n<b>$1</b>\n\nHost inválido?" 
}

# xsel já debería estar instalado :-)
SSH_HOST=$(xsel)

# 1) se é umha IP nom comprobamos e já lanzamos ssh
# 2) se termina polo sufixo da nossa rede nom comprobamos e já lanzamos ssh
# 3) comprobamos se resolve com "host" e, se resolve, lanzamos ssh
# 4) amosamos erro se nom se lanzou antes
if [[ $SSH_HOST =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
	launch_ssh $SSH_HOST
fi

# pode que copiemos dum comando "host", que devolve cum "." ao final
if [[ $SSH_HOST == *$SUFFIX_LAN || $SSH_HOST == *$SUFFIX_LAN. ]]
then
	launch_ssh $SSH_HOST
fi

# dominio que resolve pero sem sufixo
checkHost $SSH_HOST
if [ $retVal -eq 0 ]; then
	launch_ssh $SSH_HOST
fi

if [[ $SSH_HOST != *$SUFFIX_LAN ]]
then
	SSH_HOST=$SSH_HOST""$SUFFIX_LAN
	checkHost $SSH_HOST
	if [ $retVal -eq 0 ]; then
		launch_ssh $SSH_HOST
	else
		errorZenity $SSH_HOST
	fi
else
	errorZenity $SSH_HOST
fi
