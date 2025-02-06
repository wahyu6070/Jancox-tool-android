#!/system/bin/sh
#Jancox-Tool-Android
#by wahyu6070


#PATH
jancox=`dirname "$(readlink -f $0)"`
#functions
. $jancox/bin/functions
#bin
bin=$jancox/bin/$ARCH
bb=$bin/busybox
tmp=$jancox/bin/tmp
tmp3=$jancox/bin/tmp3
pybin=$jancox/bin/python
editor=$jancox/editor
profile=$jancox/bin/jancox.prop
log=$jancox/bin/jancox.log
loglive=$jancox/bin/jancox.live.log
chmod -R 755 $bin


clear
[ $(pwd) != $jancox ] && cd $jancox
del $loglive && touch $loglive
mkdir -p $tmp
mkdir -p $editor
if [ -f /data/data/com.termux/files/usr/bin/img2simg ]; then
	IMG2SIMG=/data/data/com.termux/files/usr/bin/img2simg
else
	printlog " "
	printlog "- img2simg not installed in termux !"
	printlog " "
	printlog "- apt update"
	printlog "- apt upgrade"
	printlog "- pkg install android-tools-adb"
	printlog " "
	sleep 1s
	exit
fi

if [ -f /data/data/com.termux/files/usr/bin/python ]; then
py=/data/data/com.termux/files/usr/bin/python
else
printlog " "
printlog "- python 3 Not Installed In Termux !"
printlog " "
printlog "- apt update"
printlog "- apt upgrade"
printlog "- pkg install python"
printlog " "
sleep 1s
exit
fi
printmid "${Y}Jancox Tool by wahyu6070${W}"
printlog " "
printlog "       Repack "
printlog " "
rom-info $editor
printlog " "
[ ! -d $tmp ] && mkdir $tmp
rm -rf $tmp3 && mkdir $tmp3 

if [ $tmp/META-INF ] && [ $jancox/bin/unpack.prop ]; then
	printlog "- Moving files"
	cp -rf $tmp/* $tmp3/
else
	printlog "[!] files not found, please Unpack"
fi

for IMG3 in system product system_ext vendor; do
	if [ -f $tmp3/${IMG3}.img ]; then
	printlog "- Sparsing ${IMG3}"
		$IMG2SIMG $tmp3/${IMG3}.img $tmp3/${IMG3}_sparse.img 
		rm -rf $tmp3/${IMG3}.img
		mv $tmp3/${IMG3}_sparse.img $tmp3/${IMG3}.img
	fi
done

if [ -f $tmp3/system.img ] && [ $(getp compress.dat $profile) = true ]; then
	printlog "- Repack system.img"
	[ -f $tmp3/system.new.dat ] && rm -rf $tmp3/system.new.dat
	$py $pybin/img2sdat/img2sdat.py $tmp3/system.img -o $tmp3 -v 4 >> $loglive
	[ -f $tmp3/system.img ] && rm -rf $tmp3/system.img
fi

if [ -f $tmp3/product.img ] && [ $(getp compress.dat $profile) = true ]; then
	printlog "- Repack product.img"
	[ -f $tmp3/product.new.dat ] && rm -rf $tmp3/product.new.dat
	$py $pybin/img2sdat/img2sdat.py $tmp3/product.img -o $tmp3 -v 4 -p product >> $loglive
	[ -f $tmp3/product.img ] && rm -rf $tmp3/product.img
fi

if [ -f $tmp3/system_ext.img ] && [ $(getp compress.dat $profile) = true ]; then
	printlog "- Repack system_ext.img"
	[ -f $tmp3/system_ext.new.dat ] && rm -rf $tmp3/system_ext.new.dat
	$py $pybin/img2sdat/img2sdat.py $tmp3/system_ext.img -o $tmp3 -v 4 -p system_ext >> $loglive
	[ -f $tmp3/system_ext.img ] && rm -rf $tmp3/system_ext.img
fi


if [ -f $tmp3/vendor.img ] && [ $(getp compress.dat $profile) = true ]; then
	printlog "- Repack vendor.img"
	[ -f $tmp3/vendor.new.dat ] && rm -rf $tmp3/vendor.new.dat
	$py $pybin/img2sdat/img2sdat.py $tmp3/vendor.img -o $tmp3 -v 4 -p vendor >> $loglive
	[ -f $tmp3/vendor.img ] && rm -rf $tmp3/vendor.img
fi

#level brotli
case $(getp brotli.level $jancox/bin/jancox.prop) in
1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 ) brlvl=`getp brotli.level $jancox/bin/jancox.prop` ;;
*) brlvl=1 ;;
esac
sedlog "- Brotli level : $brlvl"
if [ -f $tmp3/system.new.dat ]; then
printlog "- Repack system.new.dat"
[ -f $tmp3/system.new.dat.br ] && rm -rf $tmp3/system.new.dat.br
$bin/brotli -$brlvl -j -w 24 $tmp3/system.new.dat >> $loglive
fi

if [ -f $tmp3/product.new.dat ]; then
printlog "- Repack product.new.dat"
[ -f $tmp3/product.new.dat.br ] && rm -rf $tmp3/product.new.dat.br
$bin/brotli -$brlvl -j -w 24 $tmp3/product.new.dat >> $loglive
fi

if [ -f $tmp3/system_ext.new.dat ]; then
	printlog "- Repack system_ext.new.dat"
	[ -f $tmp3/system_ext.new.dat.br ] && rm -rf $tmp3/system_ext.new.dat.br
	$bin/brotli -$brlvl -j -w 24 $tmp3/system_ext.new.dat >> $loglive
fi


if [ -f $tmp3/vendor.new.dat ]; then
	[ -f $tmp3/vendor.new.dat.br ] && rm -rf $tmp3/vendor.new.dat.br
	printlog "- Repack vendor.new.dat"
	$bin/brotli -$brlvl -j -w 24 $tmp3/vendor.new.dat >> $loglive
fi

if [ -d $tmp3/META-INF ] && [ $(getp zipping $profile) = true ]; then
	printlog "- Zipping"
	ZIPNAME="NewROM-$(date +%Y%m%d-%H%M%S)"
	if [ "$(getp zip.level $jancox/bin/jancox.prop)" -le 9 ]; then
	ZIPLEVEL=`getp zip.level $jancox/bin/jancox.prop`
	else
	ZIPLEVEL=1
	fi
	[ -f ${ZIPNAME}.zip ] && del ${ZIPNAME}.zip
	cd $tmp3
	ZIP -r${ZIPLEVEL} $jancox/"${ZIPNAME}.zip" * #>> $loglive || sedlog "Failed creating $jancox/${zipname}.zip"
	sedlog "ZIP NAME  : ${ZIPNAME}.zip"
	sedlog "ZIP LEVEL : ${ZIPLEVEL}"
	cd $jancox
fi


if [ -f "${ZIPNAME}.zip" ]; then
      printlog "- Repack done"
      #del $tmp3
else
      printlog "- Repack error"
      #del $tmp3
fi

clog
