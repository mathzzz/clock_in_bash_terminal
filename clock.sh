#! /bin/bash

clock_is_runing() {
	local pid=0 cmd=""

	[ -r $clock ] && read pid < $clock 
	[ -r /proc/$pid/cmdline ] && read cmd < /proc/$pid/cmdline 
	test x${cmd##*/} = x${0##*/}  
	return $?
}

clock(){
	local cur=-1 
    local date="\e[7m%(%T)T\e[m"

	echo $BASHPID >$clock  
	[ -r $clock ] && exec 3</dev/zero || { echo unknow error; exit; }
	while true; do 
		[ ! -d /proc/$PPID ] && rm -f $clock
		[ ! -f $clock ] && { date="        "; unset cur; }
		printf "\e[s\e[1;$[COLUMNS-8] H$date\e[u" $cur 
		[ "$cur" != -1 ] && exit
		read  -u 3 -t 1
	done  
}


help() {
    echo "$0 [ help | exit ]"
}

clock=~/.clock.${SSH_TTY##*/}
if [ ${#@} = 0 ]; then
	if ! clock_is_runing; then
	  	clock &
	else	
		echo -e "Clock is already running in current tty.\n"
	fi
else
    case $1 in 
        exit)            
            exit;;
        help|-h|--help|-help) 
            help;;
        *) 
            help;;
    esac
fi
