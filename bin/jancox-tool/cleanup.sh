#!/system/bin/sh
#Jancox-Tool Android
#by wahyu6070


#PATH
jancox=`dirname "$(readlink -f $0)"`
#functions
. $jancox/bin/functions
clear
printmid "${Y}Jancox Tool by wahyu6070${W}"
print " "
print "       Cleanup "
print " "
print "- Cleaning"
rm -rf $jancox/bin/unpack.prop

for RM_DIR in editor; do
[ -d $jancox/$RM_DIR ] && del $jancox/$RM_DIR && print "   Removing •> $jancox/$RM_DIR"
done
for SYS in system product system_ext vendor; do
	if mount | grep -q $jancox/editor/$SYS; then
		print "- umount •> $jancox/editor/$SYS"
		umount -f $jancox/editor/$SYS
	fi
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
	*log | *tar.gz | tmp | tmp3)
	print "   Removing •> $jancox/bin/$RM_BIN"
	rm -rf $jancox/bin/$RM_BIN
	;;
	esac
done
print "- Done"
