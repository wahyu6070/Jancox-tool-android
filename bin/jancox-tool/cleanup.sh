#!/system/bin/sh
#Jancox-Tool Android
#by wahyu6070


#PATH
jancox=`dirname "$(readlink -f $0)"`
log=$jancox/bin/jancox.log
loglive=$jancox/bin/jancox.live.log
#functions
. $jancox/bin/arm/kopi
del $loglive && touch $loglive
clear
printlog "                Jancox Tool by wahyu6070"
printlog " "
printlog "       Cleanup "
printlog " "
printlog "- Cleaning"
[ -d $jancox/bin/tmp ] && del $jancox/bin/tmp
[ -d $jancox/editor ] && del $jancox/editor
[ -f  $jancox/new_rom.zip ] && del $jancox/new_rom.zip
printlog "- Done"
