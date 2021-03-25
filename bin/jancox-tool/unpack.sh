#!/system/bin/sh
#Jancox-tool-Android
#by wahyu6070


#PATH
jancox=`dirname "$(readlink -f $0)"`
#functions
. $jancox/bin/arm/kopi
#bin
bin=$jancox/bin/$ARCH32
bb=$bin/busybox
tmp=$jancox/bin/tmp
pybin=$jancox/bin/python
editor=$jancox/editor
log=$jancox/bin/jancox.log
loglive=$jancox/bin/jancox.live.log
chmod -R 755 $bin
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
if [ $input ]; then
printlog "- Using input.zip from $input "
else
printlog "${R}- Input.zip not found "
printlog "- please add input.zip in /sdcard or $jancox/ ${W}"
fi

if [ $input ]; then
printlog "- Extracting input.zip..."
$bin/unzip -o $input -d $tmp >> $loglive
listlog "$tmp"
fi

if [ -f $tmp/*.bin ]; then
printlog "- Extracting Payload.bin"
$py $pybin/payload_dumper.py $tmp/*.bin --out $tmp >> $loglive
payloadbin=true
fi

if [ -f $tmp/system.new.dat.br ]; then
printlog "- Extraction system.new.dat.br... "
$bin/brotli -d $tmp/system.new.dat.br -o $tmp/system.new.dat
del $tmp/system.new.dat.br $tmp/system.patch.dat
fi

if [ -f $tmp/vendor.new.dat.br ]; then
printlog "- Extraction vendor.new.dat.br... "
$bin/brotli -d $tmp/vendor.new.dat.br -o $tmp/vendor.new.dat
del $tmp/vendor.new.dat.br $tmp/vendor.patch.dat
fi

if [ -f $tmp/system.new.dat ]; then
printlog "- Extraction system.new.dat... "
$py $pybin/sdat2img.py $tmp/system.transfer.list $tmp/system.new.dat $tmp/system.img >> $loglive
del $tmp/system.new.dat $tmp/system.transfer.list
fi

if [ -f $tmp/vendor.new.dat ]; then
printlog "- Extraction vendor.new.dat... "
$py $pybin/sdat2img.py $tmp/vendor.transfer.list $tmp/vendor.new.dat $tmp/vendor.img >> $loglive
del $tmp/vendor.new.dat $tmp/vendor.transfer.list
fi

[ -d $jancox/editor ] && rm -rf $editor
mkdir -p $editor
if [ -f $tmp/system.img ]; then
printlog "- Extraction system.img... "
$py $pybin/imgextractor.py $tmp/system.img $editor/system >> $loglive
del $tmp/system.img
fi

if [ -f $tmp/vendor.img ]; then
printlog "- Extraction vendor.img... "
$py $pybin/imgextractor.py $tmp/vendor.img $editor/vendor >/dev/null
del $tmp/vendor.img
fi

if [ -f $tmp/boot.img ]; then
printlog "- Extraction boot.img"
$bin/magiskboot unpack $tmp/boot.img  2>> $loglive
cdir $editor/boot
for MV_BOOT in ramdisk.cpio kernel kernel_dtb dtb second; do
[ -f $jancox/$MV_BOOT ] && mv -f $jancox/$MV_BOOT $editor/boot/
sedlog "- Moving boot file $jancox/$MVBOOT to $editor/boot/"
done
fi

[ -d $tmp/META-INF ] && mv -f $tmp/META-INF $editor
[ -d $tmp/system ] && mv -f $tmp/system $editor/system2
[ -d $tmp/firmware-update ] && mv -f $tmp/firmware-update $editor
[ -d $tmp/install ] && mv -f $tmp/install $editor
[ -f $tmp/boot.img ] && mv $tmp/boot.img $editor/boot
[ -f $tmp/compatibility.zip ] && mv $tmp/compatibility.zip $editor
[ -f $tmp/system_file_contexts ] && mv -f $tmp/system_file_contexts $editor/system_file_contexts
[ -f $tmp/vendor_file_contexts ] && mv -f $tmp/vendor_file_contexts $editor/vendor_file_contexts
[ -f $tmp/system_fs_config ] && mv -f $tmp/system_fs_config $editor/system_fs_config
[ -f $tmp/vendor_fs_config ] && mv -f $tmp/vendor_fs_config $editor/vendor_fs_config

test $payloadbin && del $tmp

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
