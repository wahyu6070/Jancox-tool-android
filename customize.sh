# Nasgor Functions
. $MODPATH/bin/nasgor

ui_print "____________________________________"
ui_print "|"
ui_print "| Name            : $MODULENAME"
ui_print "| Version         : $MODULEVERSION"
ui_print "| Build date      : $MODULEDATE"
ui_print "| By              : $MODULEAUTHOR"
ui_print "|___________________________________"
ui_print "|"
ui_print "| Telegram Group  : https://t.me/wahyu6070group"
ui_print "| Youtube         : www.youtube.com/c/wahyu6070"
ui_print "|___________________________________"
ui_print "|              Device Info"
ui_print "| Name Rom        : $ANDROIDROM"
ui_print "| Android Version : $ANDROIDVERSION"
ui_print "| Kernel          : $kernel"
ui_print "| Date Install    : $(date)"
ui_print "|___________________________________"
ui_print " "

upinfo() { grep_prop $MODPATH/module.prop| cut -d "=" -f 2; }
tmp=/data/adb/jancox-tool
[ -d $tmp ] && del $tmp
mkdir -p $tmp
#Check new version
if [ $internet = online ]; then
rm -rf $tmp/module.prop
rm -rf $tmp/changelog
wget -O $tmp/module.prop https://raw.githubusercontent.com/Wahyu6070/Jancox-tool-android/master/module.prop >&2
sleep 1s
   if [ $(upinfo versionCode) -gt $MODULECODE ]; then
   ui_print "----> New Version Anvailable <------"
   ui_print "Version = $(upinfo version)"
   ui_print "Date    = $(upinfo date)"
   wget -O $tmp/changelog https://raw.githubusercontent.com/Wahyu6070/Jancox-tool-android/master/changelog >&2
   cat $tmp/changelog
   ui_print " "
   fi
fi
ui_print "- Installing python"
tar -xf $MODPATH/bin/python.tar.xz -C $MODPATH/system/lib

if [ -d /data/data/com.termux ]; then
ui_print "- Termux detected installing executable in termux"
cp -pf $MODPATH/system/bin/jancox /data/data/com.termux/usr/bin/
chmod 777 /data/data/com.termux/usr/bin/jancox
fi
ui_print "- Installing Jancox-tool files"
cp -af $MODPATH/bin/jancox-tool /data/local/

  
ui_print " "
ui_print " How to use? "
ui_print " Open terminal"
ui_print " jancox --help"
ui_print " "

chmod -R 777 /data/local/jancox-tool
set_perm $MODPATH/system/bin/jancox 0 0 0777 0777
set_perm $MODPATH/system/bin/brotli 0 0 0777 0777
set_perm $MODPATH/system/bin/jancox2 0 0 0777 0777
set_perm $MODPATH/system/bin/python 0 0 0777 0777
set_perm $MODPATH/system/bin/python3 0 0 0777 0777
set_perm $MODPATH/system/bin/python3.8 0 0 0777 0777
set_perm $MODPATH/system/bin/python-config 0 0 0777 0777
set_perm $MODPATH/system/bin/python3-config 0 0 0777 0777
set_perm $MODPATH/system/bin/python3.8-config 0 0 0777 0777
set_perm /data/local/jancox-tool/unpack.sh 0 0 0777 0777
set_perm /data/local/jancox-tool/repack.sh 0 0 0777 0777
set_perm /data/local/jancox-tool/cleanup.sh 0 0 0777 0777
$BOOTMODE || umount_apex
