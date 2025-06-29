#!/system/bin/sh
#Jancox-tool-Android
#by wahyu6070


#PATH
jancox=`dirname "$(readlink -f $0)"`
#functions
. $jancox/bin/functions
#bin
chmod -R 755 $bin
if [[ -f $jancox/bin/unpack.prop ]] && [[ ! $(getp payload $jancox/bin/unpack.prop) = "true" ]]; then
	printlog "[!] Already unpacked <cleanup.sh to reunpack>"
	for TMP_IMG in system product system_ext vendor; do
		if [ -f $tmp/${TMP_IMG}.img ] && ! mount | grep -q $editor/$TMP_IMG; then
			printlog "- Mounting <$editor/$TMP_IMG>"
			[ ! -d $editor/$TMP_IMG ] && mkdir $editor/$TMP_IMG 
			mount -o loop $tmp/${TMP_IMG}.img $editor/$TMP_IMG
		fi
	done
	exit 0
fi
[ $(pwd) != $jancox ] && cd $jancox
del $loglive && touch $loglive
[ -d $tmp ] && del $tmp
[ -d $editor ] && del $editor
cdir $tmp
cdir $editor
if [ -f /data/data/com.termux/files/usr/bin/python ]; then
py=/data/data/com.termux/files/usr/bin/python
else
printlog " "
printlog "$- python 3 Not Installed In Termux !"
printlog " "
printlog "- apt update"
printlog "- apt upgrade"
printlog "- pkg install python"
printlog " "
sleep 1s
exit
fi
#input.zip
for ajax in $jancox /data/media/0 /data/media/0/Download; do
     if [ -f $ajax/input.zip ]; then
        input=$ajax/input.zip
        break
     fi;
done
clear
[ ! -f $jancox/credits.txt ] && printlog "    Credits not found !!" | sleep 3s | exit ;

printmid "${Y}Jancox Tool by wahyu6070${W}"
printlog " "
printlog "       Unpack"
printlog " "

echo "unpack=true" > $jancox/bin/unpack.prop
if [ $input ]; then
printlog "- Using input.zip from $input "
else
printlog "${R}- Input.zip not found "
printlog "- please add input.zip in /sdcard or $jancox/ ${W}"
fi

if [ $input ]; then
	printlog "- Extracting input.zip..."
	UNZIP $input $tmp
	listlog "$tmp"
fi

if [ -f $tmp/*.bin ]; then
	printlog "- Extracting Payload.bin"
	PAYLOAD -output $tmp $tmp/*.bin >> $loglive
	echo "payload=true" >> $jancox/bin/unpack.prop
fi

if [ -f $tmp/system.new.dat.br ]; then
	printlog "- Extraction system.new.dat.br... "
	BROTLI -d $tmp/system.new.dat.br -o $tmp/system.new.dat
	del $tmp/system.new.dat.br $tmp/system.patch.dat
fi

if [ -f $tmp/product.new.dat.br ]; then
	printlog "- Extraction product.new.dat.br... "
	BROTLI -d $tmp/product.new.dat.br -o $tmp/product.new.dat
	del $tmp/product.new.dat.br $tmp/product.patch.dat
fi

if [ -f $tmp/system_ext.new.dat.br ]; then
	printlog "- Extraction system_ext.new.dat.br... "
	BROTLI -d $tmp/system_ext.new.dat.br -o $tmp/system_ext.new.dat
	del $tmp/system_ext.new.dat.br $tmp/system_ext.patch.dat
fi

if [ -f $tmp/vendor.new.dat.br ]; then
	printlog "- Extraction vendor.new.dat.br... "
	BROTLI -d $tmp/vendor.new.dat.br -o $tmp/vendor.new.dat
	del $tmp/vendor.new.dat.br $tmp/vendor.patch.dat
fi


if [ -f $tmp/system.new.dat ]; then
	printlog "- Extraction system.new.dat... "
	$py $pybin/sdat2img/sdat2img.py $tmp/system.transfer.list $tmp/system.new.dat $tmp/system.img >> $loglive
	del $tmp/system.new.dat $tmp/system.transfer.list
fi

if [ -f $tmp/product.new.dat ]; then
	printlog "- Extraction product.new.dat... "
	$py $pybin/sdat2img/sdat2img.py $tmp/product.transfer.list $tmp/product.new.dat $tmp/product.img >> $loglive
	del $tmp/product.new.dat $tmp/product.transfer.list
fi

if [ -f $tmp/system_ext.new.dat ]; then
	printlog "- Extraction system_ext.new.dat... "
	$py $pybin/sdat2img/sdat2img.py $tmp/system_ext.transfer.list $tmp/system_ext.new.dat $tmp/system_ext.img >> $loglive
	del $tmp/system_ext.new.dat $tmp/system_ext.transfer.list
fi


if [ -f $tmp/vendor.new.dat ]; then
	printlog "- Extraction vendor.new.dat... "
	$py $pybin/sdat2img/sdat2img.py $tmp/vendor.transfer.list $tmp/vendor.new.dat $tmp/vendor.img >> $loglive
	del $tmp/vendor.new.dat $tmp/vendor.transfer.list
fi

[ -d $jancox/editor ] && rm -rf $editor
mkdir -p $editor

if [[ "$(getp payload $jancox/bin/unpack.prop)" == "true" ]]; then
	
	for SBIN in system vendor product system_ext; do
		if [ -f $tmp/${SBIN}.img ]; then
			printlog "- Extraction $SBIN.img... "
			mkdir -p $editor/$SBIN
			$py $pybin/imgextractor/imgextractor.py $tmp/${SBIN}.img $editor/$SBIN
		fi
	done
else
	for SBIN in system vendor product system_ext; do
		if [ -f $tmp/${SBIN}.img ]; then
			printlog "- Mounting ${SBIN}.img... "
			mkdir -p $editor/$SBIN
			mount -o loop $tmp/${SBIN}.img $editor/${SBIN}
		fi
	done
fi


if [ -f $editor/system/build.prop ]; then
	printlog "- Done "
	printlog " "
	rom-info $editor > $editor/rom-info
elif [ -f $editor/system/system/build.prop ]; then
	printlog "- Done"
	printlog " "
	rom-info $editor > $editor/rom-info
	cat $editor/rom-info
else
	printlog "- Finished with the problem"
fi
