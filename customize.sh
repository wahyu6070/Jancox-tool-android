
print(){
	echo "$1"
	}
getp(){ grep "^$1" "$2" | head -n1 | cut -d = -f 2; }

MODULEVERSION=`getp version $MODPATH/module.prop`
MODULECODE=`getp versionCode $MODPATH/module.prop`
MODULENAME=`getp name $MODPATH/module.prop`
MODULEANDROID=`getp android $MODPATH/module.prop`
MODULEDATE=`getp date $MODPATH/module.prop`
MODULEAUTHOR=`getp author $MODPATH/module.prop`

print "____________________________________"
print "|"
print "| Name            : $MODULENAME"
print "| Version         : $MODULEVERSION"
print "| Build date      : $MODULEDATE"
print "| By              : $MODULEAUTHOR"
print "|___________________________________"
print "|"
print "| Telegram Group  : https://t.me/wahyu6070group"
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

if [ ! -d /data/local/jancox-tool/bin ]; then
	print "[ERROR] Installing Jancox-tool files"
fi
  
print " "
print " How to use? "
print " Open terminal"
print " jancox --help"
print " "

chmod -R 755 /data/local/jancox-tool
chmod 755 $MODPATH/system/bin/jancox

