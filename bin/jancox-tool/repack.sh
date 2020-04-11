#!/system/bin/sh
#jancox tool
#by wahyu6070

case $0 in
  *.sh) jancox="$0";;
     *) jancox="$(lsof -p $$ 2>/dev/null | grep -o '/.*repack.sh$')";;
esac;

#PATH
jancox="$(dirname "$(readlink -f "$jancox")")";
#functions
. $jancox/bin/arm/nasgor
#bin
bin=$jancox/bin/$ARCH32
bb=$bin/busybox
tmp=$jancox/bin/tmp
pybin=$jancox/bin/python
editor=$jancox/editor
profile=$jancox/bin/jancox.prop
chmod -R 777 $bin
clear
[ $(pwd) != $jancox ] && cd $jancox
if [ ! -d $editor/system ]; then print "     Please Unpack !!"; exit; fi
mkdir -p $tmp
mkdir -p $editor
if [ -f /data/data/com.termux/files/usr/bin/python ]; then
py=/data/data/com.termux/files/usr/bin/python
else
py=python
fi
print "                Jancox Tool by wahyu6070"
print "       Repack "
print " "
rom-info $editor
print " "
[ ! -d $tmp ] && mkdir $tmp

if [[ $(grep_profile set.time) == true ]]; then
setime -r $editor/system 200901010000 $nul
setime -r $editor/vendor 200901010000 $nul
fi

if [ -d $editor/system ]; then
print "- Repack system"
size1=`du -sk $editor/system | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
$bin/make_ext4fs -s -L system -T 2009110000 -S $editor/system_file_contexts -C $editor/system_fs_config -l $size1 -a system $tmp/system.img $editor/system/ > /dev/null
fi

if [ -d $editor/vendor ]; then
print "- Repack vendor"
size2=`du -sk $editor/vendor | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
$bin/make_ext4fs -s -L vendor -T 2009110000 -S $editor/vendor_file_contexts -C $editor/vendor_fs_config -l $size2 -a vendor $tmp/vendor.img $editor/vendor/ > /dev/null
fi;


if [ -f $tmp/system.img ]; then
print "- Repack system.img"
[ -f $tmp/system.new.dat ] && rm -rf $tmp/system.new.dat
$py $pybin/img2sdat.py $tmp/system.img -o $tmp -v 4 > /dev/null
[ -f $tmp/system.img ] && rm -rf $tmp/system.img
fi

if [ -f $tmp/vendor.img ]; then
print "- Repack vendor.img"
[ -f $tmp/vendor.new.dat ] && rm -rf $tmp/vendor.new.dat
$py $pybin/img2sdat.py $tmp/vendor.img -o $tmp -v 4 -p vendor > /dev/null
[ -f $tmp/vendor.img ] && rm -rf $tmp/vendor.img
fi

#level brotli
brlvl=$(get_prop brotli.level $jancox/bin/jancox.prop)
#
if [ -f $tmp/system.new.dat ]; then
print "- Repack system.new.dat"
[ -f $tmp/system.new.dat.br ] && rm -rf $tmp/system.new.dat.br
$bin/brotli -$brlvl -j -w 24 $tmp/system.new.dat >/dev/null
fi

if [ -f $tmp/vendor.new.dat ]; then
[ -f $tmp/vendor.new.dat.br ] && rm -rf $tmp/vendor.new.dat.br
print "- Repack vendor.new.dat"
$bin/brotli -$brlvl -j -w 24 $tmp/vendor.new.dat >/dev/null
fi

if [ -d $editor/boot ] && [ -f $editor/boot/boot.img ]; then
print "- Repack boot"
[ -f $editor/boot/kernel ] && cp -f $editor/boot/kernel $jancox
[ -f $editor/boot/kernel_dtb ] && cp -f $editor/boot/kernel_dtb $jancox
[ -f $editor/boot/ramdisk.cpio ] && cp -f $editor/boot/ramdisk.cpio $jancox
[ -f $editor/boot/second ] && cp -f $editor/boot/second $jancox
$bin/magiskboot repack $editor/boot/boot.img 2>/dev/null
sleep 1s
[ -f $jancox/new-boot.img ] && mv -f $jancox/new-boot.img $tmp/boot.img
rm -rf $jancox/kernel $jancox/kernel_dtb $jancox/ramdisk.cpio $jancox/second >/dev/null 2>/dev/null
fi

[ -d $editor/META-INF ] && cp -a $editor/META-INF $tmp/
[ -d $editor/install ] && cp -a $editor/install $tmp/
[ -d $editor/system2 ] && cp -a $editor/system2 $tmp/system
[ -d $editor/firmware-update ] && cp -a $editor/firmware-update $tmp/
[ -f $editor/compatibility.zip ] && cp -f $editor/compatibility.zip $tmp/
[ -f $editor/compatibility_no_nfc.zip ] && cp -f $editor/compatibility_no_nfc.zip $tmp/

if [ -d $tmp/META-INF ]; then
print "- Zipping"
[ -f ./new_rom.zip ] && rm -rf ./new_rom.zip
$bin/7za a -tzip $jancox/new_rom.zip $tmp/* | nul
fi


if [ -f ./new_rom.zip ]; then
      print "- Repack done"
      del $tmp
else
      print "- Repack error"
      del $tmp
fi
