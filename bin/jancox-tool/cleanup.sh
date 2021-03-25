#!/system/bin/sh
#Jancox-Tool Android
#by wahyu6070


#PATH
jancox=`dirname "$(readlink -f $0)"`
#functions
. $jancox/bin/arm/kopi
clear
printmid "${Y}Jancox Tool by wahyu6070${W}"
print " "
print "       Cleanup "
print " "
print "- Cleaning"
for RM_DIR in editor; do
[ -d $jancox/$RM_DIR ] && del $jancox/$RM_DIR && print "   Removing •> $jancox/$RM_DIR"
done
for RM_FILES in $(ls -1 $jancox); do
	case "$RM_FILES" in
		*new-rom*)
			print "   Removing •> $jancox/$RM_FILES"
			rm -rf $jancox/$RM_FILES
			;;
	esac
done
for RM_BIN in $(ls -1 $jancox/bin); do
	case $RM_BIN in
	*log | *tar.gz | tmp)
	print "   Removing •> $jancox/bin/$RM_BIN"
	rm -rf $jancox/bin/$RM_BIN
	;;
	esac
done
print "- Done"
