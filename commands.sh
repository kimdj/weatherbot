#!/usr/bin/env bash
# busbot ~ Subroutines/Commands
# Copyright (c) 2017 David Kim
# This program is licensed under the "MIT License".
# Date of inception: 2/4/18

read nick chan msg      # Assign the 3 arguments to nick, chan and msg.

IFS=''                  # internal field separator; variable which defines the char(s)
                        # used to separate a pattern into tokens for some operations
                        # (i.e. space, tab, newline)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BOT_NICK="$(grep -P "BOT_NICK=.*" ${DIR}/busbot.sh | cut -d '=' -f 2- | tr -d '"')"

if [ "${chan}" = "${BOT_NICK}" ] ; then chan="${nick}" ; fi

###################################################  Settings  ####################################################

AUTHORIZED='_sharp MattDaemon'

###############################################  Subroutines Begin  ###############################################

function has { $(echo "${1}" | grep -P "${2}" > /dev/null) ; }

function say { echo "PRIVMSG ${1} :${2}" ; }

function send {
    while read -r line; do                          # -r flag prevents backslash chars from acting as escape chars.
      currdate=$(date +%s%N)                         # Get the current date in nanoseconds (UNIX/POSIX/epoch time) since 1970-01-01 00:00:00 UTC (UNIX epoch).
      if [ "${prevdate}" -gt "${currdate}" ] ; then  # If 0.5 seconds hasn't elapsed since the last loop iteration, sleep. (i.e. force 0.5 sec send intervals).
        sleep $(bc -l <<< "(${prevdate} - ${currdate}) / ${nanos}")
        currdate=$(date +%s%N)
      fi
      prevdate=${currdate}+${interval}
      echo "-> ${1}"
      echo "${line}" >> ${BOT_NICK}.io
    done <<< "${1}"
}

# This subroutine looks up bus stop information.

function busSubroutine {
    payload="${1}"

    python trimet.py "${payload}" > output.tmp

    sed -i -r "1s|(.*)|           Line #  ==>  \1|" output.tmp

    epoch=$(cat output.tmp | sed -n 2p)
    epoch_converted="$(date --date="@${epoch}")"
    sed -i "2s|.*|Next Arrival Time  ==>  ${epoch_converted}|" output.tmp

    sed -i -r "3s|(.*)|       Short Sign  ==>  \1|" output.tmp

    sed -i -r "4s|(.*)|        Long Sign  ==>  \1|" output.tmp

    if [ -s output.tmp ] ; then
        say ${chan} "          Stop ID  ==>  ${payload}"
        while read -r line ; do                                 # -r flag prevents backslash chars from acting as escape chars.
            say ${chan} "${line}"
        done < output.tmp
    else
        say ${chan} "Sorry, there's a problem.."
    fi
}

# This subroutine displays documentation for busbot's functionalities.

function helpSubroutine {
    say ${chan} "usage: !bus [stopID]"
}

################################################  Subroutines End  ################################################

# Ω≈ç√∫˜µ≤≥÷åß∂ƒ©˙∆˚¬…ææœ∑´®†¥¨ˆøπ“‘¡™£¢∞••¶•ªº–≠«‘“«`
# ─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┐┑┒┓└┕┖┗┘┙┚┛├┝┞┟┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┰┱┲┳┴┵┶┷┸┹┺┻┼┽┾┿╀╁╂╃╄╅╆╇╈╉╊╋╌╍╎╏
# ═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╰╱╲╳╴╵╶╷╸╹╺╻╼╽╾╿

################################################  Commands Begin  #################################################

# Help Command.

if has "${msg}" "^!busbot$" || has "${msg}" "^busbot: help$" || has "${msg}" "^!bus$" ; then
    helpSubroutine

# Alive.

elif has "${msg}" "^!alive(\?)?$" || has "${msg}" "^busbot: alive(\?)?$" ; then
    str1='running! '
    str2=$(ps aux | grep ./busbot | head -n 1 | awk '{ print "[%CPU "$3"]", "[%MEM "$4"]", "[START "$9"]", "[TIME "$10"]" }')
    str3=" [TOT_SIZE $(du -sh | cut -f -1)]"
    str="${str1}${str2}${str3}"
    say ${chan} "${str}"

# Source.

elif has "${msg}" "^busbot: source$" ||
     has "${msg}" "^!busbot source$" ; then
    say ${chan} "Try -> https://github.com/kimdj/busbot, /u/dkim/busbot"

# Get bus stop schedule.

elif has "${msg}" "^!bus " ; then
    payload=$(echo ${msg} | sed -r 's/^!bus //')
    busSubroutine "${payload}"

# Have busbot send an IRC command to the IRC server.

elif has "${msg}" "^busbot: injectcmd " && [[ "${AUTHORIZED}" == *"${nick}"* ]] ; then
    cmd=$(echo ${msg} | sed -r 's/^busbot: injectcmd //')
    send "${cmd}"

# Have busbot send a message.

elif has "${msg}" "^busbot: sendcmd " && [[ "${AUTHORIZED}" == *"${nick}"* ]] ; then
    buffer=$(echo ${msg} | sed -re 's/^busbot: sendcmd //')
    dest=$(echo ${buffer} | sed -e "s| .*||")
    message=$(echo ${buffer} | cut -d " " -f2-)
    say ${dest} "${message}"

fi

#################################################  Commands End  ##################################################
