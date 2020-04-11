#!/system/bin/sh
#
#

case $0 in
  *.sh) jancox="$0";;
     *) jancox="$(lsof -p $$ 2>/dev/null | grep -o '/.*cleanup.sh$')";;
esac;

#PATH
jancox="$(dirname "$(readlink -f "$jancox")")";
#functions
. $jancox/bin/arm/nasgor
clear
print "                Jancox Tool by wahyu6070"
print " "
print "       Cleanup "
print " "
print "- Cleaning"
[ -d $jancox/bin/tmp ] && del $jancox/bin/tmp
[ -d $jancox/editor ] && del $jancox/editor
[ -f  $jancox/new_rom.zip ] && del $jancox/new_rom.zip
print "- Done"