#! /bin/bash

_clock_is_runing() {
	local pid=0 cmd=""

	[ -r $clock ] && read pid < $clock 
	[ -r /proc/$pid/cmdline ] && read cmd < /proc/$pid/cmdline 
	test x${cmd##*/} = x${0##*/}  
	return $?
}

_clock(){
	local cur=-1 
    local date="\e[7m%(%T)T\e[m"

	echo $BASHPID >$clock  
    [ ! -e $clock.fifo ] && mkfifo $clock.fifo
    exec 3<>$clock.fifo
    cols=$COLUMNS
    line=$LINES
	[ -r $clock ] || _exit "echo unknow error."
	while true; do 
		[ ! -d /proc/$PPID ] && rm -f $clock
		[ ! -f $clock ] && { date="        "; unset cur; }
        if [ -n "$cols" ] ; then 
		    printf "\e[s\e[1;$[COLUMNS-7]H         \e[u"
            COLUMNS=$cols
            LINES=$line
        fi
		printf "\e[s\e[1;$[COLUMNS-7]H$date\e[u" $cur 
		[ "$cur" != -1 ] && exit
		read -u 3 -t 1 line cols 
	done  

}


_help() {
    echo "$0 [ help | exit ]"
}

_exit() {
    rm -f $clock
    echo "$@"
    builtin exit
}

clock=~/.clock.${SSH_TTY##*/}
if [ ${#@} = 0 ]; then
	if ! _clock_is_runing; then
	  	_clock &
	else	
		echo -e "Clock is already running in current tty.\n"
	fi
else
    case $1 in 
        exit)            
            _exit;;
        help|-h|--help|-help) 
            _help;;
        *) 
            _help;;
    esac
fi

#trap 'echo $LINES $COLUMNS >~/.clock.1.fifo' 28
