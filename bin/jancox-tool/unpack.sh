#!/system/bin/sh
#Jancox-tool
#by wahyu6070 @xda-developers


case $0 in
  *.sh) jancox="$0";;
     *) jancox="$(lsof -p $$ 2>/dev/null | grep -o '/.*unpack.sh$')";;
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
chmod -R 777 $bin
[ $(pwd) != $jancox ] && cd $jancox
[ -d $tmp ] && rm -rf $tmp
[ -d $editor ] && rm -rf $editor
mkdir -p $tmp
mkdir -p $editor
if [ -f /data/data/com.termux/files/usr/bin/python ]; then
py=/data/data/com.termux/files/usr/bin/python
else
py=python
fi
#input.zip
for ajax in $jancox /data/media/0 /data/media/0/download; do
     if [ -f $ajax/input.zip ]; then
        input=$ajax/input.zip
        break
     fi;
done
clear
[ ! -f $jancox/credits.txt ] && print "    Credits not found !!" | sleep 3s | exit ;

print "                Jancox Tool by wahyu6070"
print " "
print "       Unpack "
print " "
if [ -f $IN ]; then
print "- Using input.zip from $input "
else
print "- Input.zip not found "
print "- please add input.zip in /sdcard or $jancox/input.zip"
fi

if [ -f $input ]; then
print "- Extrack input.zip..."
$bb unzip -o $input -d $tmp >/dev/null 2>&1
fi

if [ -f $tmp/system.new.dat.br ]; then
print "- Extraction system.new.dat.br... "
$bin/brotli -d $tmp/system.new.dat.br -o $tmp/system.new.dat
rm -rf $tmp/system.new.dat.br $tmp/system.patch.dat
fi

if [ -f $tmp/vendor.new.dat.br ]; then
print "- Extraction vendor.new.dat.br... "
$bin/brotli -d $tmp/vendor.new.dat.br -o $tmp/vendor.new.dat
rm -rf $tmp/vendor.new.dat.br $tmp/vendor.patch.dat
fi

if [ -f $tmp/system.new.dat ]; then
print "- Extraction system.new.dat... "
$py $pybin/sdat2img.py $tmp/system.transfer.list $tmp/system.new.dat $tmp/system.img > /dev/null
rm -rf $tmp/system.new.dat $tmp/system.transfer.list
fi

if [ -f $tmp/vendor.new.dat ]; then
print "- Extraction vendor.new.dat... "
$py $pybin/sdat2img.py $tmp/vendor.transfer.list $tmp/vendor.new.dat $tmp/vendor.img > /dev/null
rm -rf $tmp/vendor.new.dat $tmp/vendor.transfer.list
fi

[ -d $jancox/editor ] && rm -rf $editor
mkdir -p $editor
if [ -f $tmp/system.img ]; then
print "- Extraction system.img... "
$py $pybin/imgextractor.py $tmp/system.img $editor/system >/dev/null
rm -rf $tmp/system.img
fi

if [ -f $tmp/vendor.img ]; then
print "- Extraction vendor.img... "
$py $pybin/imgextractor.py $tmp/vendor.img $editor/vendor >/dev/null
rm -rf $tmp/vendor.img
fi

if [ -f $tmp/boot.img ]; then
print "- Extraction boot.img"
$bin/magiskboot unpack $tmp/boot.img 2>/dev/null
mkdir -p $editor/boot
[ -f $jancox/ramdisk.cpio ] && mv -f $jancox/ramdisk.cpio $editor/boot/
[ -f $jancox/kernel ] && mv -f $jancox/kernel $editor/boot/
[ -f $jancox/kernel_dtb ] && mv -f $jancox/kernel_dtb $editor/boot/
[ -f $jancox/second ] && mv -f $jancox/kernel_dtb $editor/boot/
fi

[ -d $tmp/META-INF ] && mv -f $tmp/META-INF $editor
[ -d $tmp/system ] && mv -f $tmp/system $editor/system2
[ -d $tmp/firmware-update ] && mv -f $tmp/META-INF $editor
[ -d $tmp/install ] && mv -f $tmp/install $editor
[ -f $tmp/boot.img ] && mv $tmp/boot.img $editor/boot
[ -f $tmp/compatibility.zip ] && mv $tmp/compatibility.zip $editor
[ -f $tmp/system_file_contexts ] && mv -f $tmp/system_file_contexts $editor/system_file_contexts
[ -f $tmp/vendor_file_contexts ] && mv -f $tmp/vendor_file_contexts $editor/vendor_file_contexts
[ -f $tmp/system_fs_config ] && mv -f $tmp/system_fs_config $editor/system_fs_config
[ -f $tmp/vendor_fs_config ] && mv -f $tmp/vendor_fs_config $editor/vendor_fs_config
if [ -f $editor/system/build.prop ]; then
print "- Done "
print " "
rom-info $editor
elif [ -f $editor/system/system/build.prop ]; then
print "- Done"
print " "
rom-info $editor
else
print "- Finished with the problem"
fi
