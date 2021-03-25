print "____________________________________"
print "|"
print "| Name            : $NAME"
print "| Version         : $VERSION"
print "| Build date      : $DATE"
print "| By              : $AUTHOR"
print "|___________________________________"
print "|"
print "| Telegram Group  : https://t.me/wahyu6070group"
print "| Youtube         : www.youtube.com/c/wahyu6070"
print "|___________________________________"

if [ -d /data/data/com.termux ]; then
print "- Termux detected installing executable in termux"
test -f /data/data/com.termux/files/usr/bin/jancox && rm -rf /data/data/com.termux/files/usr/bin/jancox
cp -pf $MODPATH/system/bin/jancox /data/data/com.termux/files/usr/bin/
chmod 755 /data/data/com.termux/files/usr/bin/jancox
fi

if [ -d $MODPATH/bin/jancox-tool ]; then
test -d /data/local/jancox-tool && rm -rf /data/local/jancox-tool
print "- Installing Jancox-tool files"
cp -af $MODPATH/bin/jancox-tool /data/local/
chmod 755 /data/local/jancox-tool
fi
  
print " "
print " How to use? "
print " Open terminal"
print " jancox --help"
print " "

chmod -R 755 /data/local/jancox-tool
chmod 755 $MODPATH/system/bin/jancox
chnod 755 $MODPATH/system/bin/jancoxmenu
