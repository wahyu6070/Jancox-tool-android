#!/system/bin/sh
#Jancox-tool-Android
#by wahyu6070


#PATH
JANCOX=`dirname "$(readlink -f $0)"`
#functions
chmod 755 $JANCOX/bin/jancox_functions
. $JANCOX/bin/jancox_functions

[ $(pwd) != $JANCOX ] && cd $JANCOX

for T in $TMP $TMP2 $EDITOR; do
	 [ -d $T ] && del $T && cdir $T || cdir $T
done

#input.zip
for ajax in $JANCOX /data/media/0 /data/media/0/Download; do
     if [ -f $ajax/input.zip ]; then
        INPUT=$ajax/input.zip
        break
     fi;
done
clear
[ ! -f $JANCOX/credits.txt ] && printlog "    Credits not found !!" | sleep 3s | exit ;

printmid "${Y}Jancox Tool by wahyu6070${W}"
printlog " "
printlog "       Unpack"
printlog " "
if [ $INPUT ]; then
	printlog "- Using input.zip from $INPUT "
else
	printlog "${R}- Input.zip not found "
	printlog "- please add input.zip in /sdcard or $JANCOX/ ${W}"
fi

if [ $INPUT ]; then
	printlog "- Extracting input.zip..."
	$BIN/unzip -o $INPUT -d $TMP >> $LOG
fi


if [ -f $TMP/*.bin ]; then
	printlog "- Extracting Payload.bin"
	$PYTHON $pybin/payload_dumper.py $tmp/*.bin --out $tmp >> $LOG
	payloadbin=true
fi

if [ -f $TMP/system.new.dat.br ]; then
	printlog "- Extraction system.new.dat.br... "
	$BIN/brotli -d $TMP/system.new.dat.br -o $TMP2/system.new.dat
fi

if [ -f $TMP/product.new.dat.br ]; then
	printlog "- Extraction product.new.dat.br... "
	$BIN/brotli -d $TMP/product.new.dat.br -o $TMP2/product.new.dat
fi

if [ -f $TMP/system_ext.new.dat.br ]; then
	printlog "- Extraction system_ext.new.dat.br... "
	$BIN/brotli -d $TMP/system_ext.new.dat.br -o $TMP2/system_ext.new.dat
fi

if [ -f $TMP/vendor.new.dat.br ]; then
	printlog "- Extraction vendor.new.dat.br... "
	$BIN/brotli -d $TMP/vendor.new.dat.br -o $TMP2/vendor.new.dat
fi

if [ -f $TMP2/system.new.dat ]; then
	printlog "- Extraction system.new.dat... "
	$PYTHON $JANCOX/bin/sdat2img/sdat2img.py $TMP/system.transfer.list $TMP2/system.new.dat $TMP2/system.img >> $LOG
	del $TMP2/system.new.dat
fi

if [ -f $TMP2/product.new.dat ]; then
	printlog "- Extraction product.new.dat... "
	$PYTHON $JANCOX/bin/sdat2img/sdat2img.py $TMP/product.transfer.list $TMP2/product.new.dat $TMP2/product.img >> $LOG
	del $TMP2/product.new.dat
fi

if [ -f $TMP2/system_ext.new.dat ]; then
	printlog "- Extraction system_ext.new.dat... "
	$PYTHON $JANCOX/bin/sdat2img/sdat2img.py $TMP/system_ext.transfer.list $TMP2/system_ext.new.dat $TMP2/system_ext.img >> $LOG
	del $TMP2/system_ext.new.dat
fi

if [ -f $TMP2/vendor.new.dat ]; then
	printlog "- Extraction vendor.new.dat... "
	$PYTHON $JANCOX/bin/sdat2img/sdat2img.py $TMP/vendor.transfer.list $TMP2/vendor.new.dat $TMP2/vendor.img >> $LOG
	del $TMP2/vendor.new.dat
fi

[ -d $EDITOR ] && del $EDITOR
cdir $EDITOR

if [ -f $TMP2/system.img ]; then
	printlog "- Extraction system.img... "
	$PYTHON $JANCOX/bin/imgextractor/imgextractor.py $TMP2/system.img $EDITOR/system >> $LOG
	del $TMP2/system.img
fi

if [ -f $TMP2/product.img ]; then
	printlog "- Extraction product.img... "
	$PYTHON $JANCOX/bin/imgextractor/imgextractor.py $TMP2/product.img $EDITOR/product >> $LOG
	del $TMP2/product.img
fi

if [ -f $TMP2/system_ext.img ]; then
	printlog "- Extraction system.img... "
	$PYTHON $JANCOX/bin/imgextractor/imgextractor.py $TMP2/system_ext.img $EDITOR/system_ext >> $LOG
	del $TMP2/system_ext.img
fi

if [ -f $TMP/vendor.img ]; then
	printlog "- Extraction vendor.img... "
	$PYTHON $JANCOX/bin/imgextractor/imgextractor.py $TMP2/vendor.img $EDITOR/vendor >> $LOG
	del $TMP2/vendor.img
fi

if [ -f $TMP/boot.img ]; then
	printlog "- Extraction boot.img"
	$BIN/magiskboot unpack $TMP/boot.img >> $LOG
	cdir $EDITOR/boot
	for MV_BOOT in ramdisk.cpio kernel kernel_dtb dtb second; do
		[ -f $JANCOX/$MV_BOOT ] && mv -f $JANCOX/$MV_BOOT $EDITOR/boot/
		sedlog "- Moving boot file $JANCOX/$MVBOOT to $EDITOR/boot/"
	done
fi

#test $payloadbin && del $tmp

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
