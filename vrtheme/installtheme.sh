#!/sbin/sh
# Copyright VillainROM 2011. All Rights Reserved
# Updated for later Android versions by Spannaa @ XDA 2016

# function to allow ui_print from sh
ui_print() {
  if [ $recovery_binary != "" ]; then
    echo "ui_print ${1} " 1>&$recovery_binary;
    echo "ui_print " 1>&$recovery_binary;
  else
    echo "${1}";
  fi;
}

# function to get build.prop value
get_prop_value(){
	rtn_val=`cat $1|grep "^$2="|cut -d"=" -f2|tr -d '\r '`
	echo $rtn_val
}

# function to select file locations based on rom version
set_paths(){
if [ $rom_version -ge $android_5 ]; then
    dir="/$1"
	apk="$1.apk"
	dex="@$1"
	arm="/arm"
	arm64="/arm64"
else
	dir=""
	apk="$1"
	dex=""
	arm=""
	arm64=""
fi
}

# find which recovery is being used
cwm_run=$(ps | grep -v "grep" | grep -o -E "update_binary(.*)" | cut -d " " -f 3);
twrp_run=$(ps | grep -v "grep" | grep -o -E "updater(.*)" | cut -d " " -f 3);
if [ "$cwm_run" ]; then
	recovery_binary=$cwm_run
else
if [ "$twrp_run" ]; then
	recovery_binary=$twrp_run
fi
fi

# grab build.prop & rom version
build_prop=/system/build.prop
os_ver=`get_prop_value $build_prop "ro.build.version.release"`
android_5=5
rom_version=`echo "$os_ver" | cut -d. -f1`

# start with /system/app
[ -d /data/tmp/vrtheme/system/app ] && systemapps=1 || systemapps=0
if [ "$systemapps" -eq "1" ]; then
cd /data/tmp/vrtheme/system/app/
ui_print "   Processing /system/app"
for f in $(ls)
do
	set_paths $f
	ui_print "     $apk"
	busybox mkdir -p /data/tmp/vrtheme-backup/system/app$dir
	busybox mkdir -p /data/tmp/vrtheme/apply/system/app$dir/aligned
# get apk
  cp /system/app$dir/$apk /data/tmp/vrtheme/apply/system/app$dir/
# backup apk
	cp /system/app$dir/$apk /data/tmp/vrtheme-backup/system/app$dir/
# patch apk
	cd /data/tmp/vrtheme/system/app$dir/$apk/
  /data/tmp/vrtheme/zip -r /data/tmp/vrtheme/apply/system/app$dir/$apk *
# if classes.dex is included, delete dalvik-cache entry if it exists
	if [ -f classes.dex ]; then
		dc_file=/data/dalvik-cache$arm/system@app$dex@$apk@classes.dex
		dc_file_64=/data/dalvik-cache$arm64/system@app$dex@$apk@classes.dex
		if [ -f $dc_file ]; then
			rm -f $dc_file
			ui_print "       Old dalvik-cache entry deleted"
		fi
		if [ -f $dc_file_64 ]; then
			rm -f $dc_file_64
			ui_print "       Old dalvik-cache entry deleted"
		fi
	fi
	# zipalign apk
	cd /data/tmp/vrtheme/apply/system/app$dir/
	/data/tmp/vrtheme/zipalign -f 4 $apk aligned/$apk
# move apk back
	cp aligned/$apk /system/app$dir/
	chmod 644 /system/app$dir/$apk
done
fi

# repeat for /system/priv-app
[ -d /data/tmp/vrtheme/system/priv-app ] && systemprivapps=1 || systemprivapps=0
if [ "$systemprivapps" -eq "1" ]; then
cd /data/tmp/vrtheme/system/priv-app/
ui_print "   Processing /system/priv-app"
for f in $(ls)
do
	set_paths $f
	ui_print "     $apk"
	busybox mkdir -p /data/tmp/vrtheme-backup/system/priv-app$dir
	busybox mkdir -p /data/tmp/vrtheme/apply/system/priv-app$dir/aligned
# get apk
  cp /system/priv-app$dir/$apk /data/tmp/vrtheme/apply/system/priv-app$dir/
# backup apk
	cp /system/priv-app$dir/$apk /data/tmp/vrtheme-backup/system/priv-app$dir/
# patch apk
	cd /data/tmp/vrtheme/system/priv-app$dir/$apk/
  /data/tmp/vrtheme/zip -r /data/tmp/vrtheme/apply/system/priv-app$dir/$apk *
# if classes.dex is included, delete dalvik-cache entry if it exists
	if [ -f classes.dex ]; then
		dc_file=/data/dalvik-cache$arm/system@app$dex@$apk@classes.dex
		dc_file_64=/data/dalvik-cache$arm64/system@app$dex@$apk@classes.dex
		if [ -f $dc_file ]; then
			rm -f $dc_file
			ui_print "       Old dalvik-cache entry deleted"
		fi
		if [ -f $dc_file_64 ]; then
			rm -f $dc_file_64
			ui_print "       Old dalvik-cache entry deleted"
		fi
	fi
# zipalign apk
	cd /data/tmp/vrtheme/apply/system/priv-app$dir/
	/data/tmp/vrtheme/zipalign -f 4 $apk aligned/$apk
# move apk back
	cp aligned/$apk /system/priv-app$dir/
	chmod 644 /system/priv-app$dir/$apk
done
fi

# repeat for /preload/symlink/system/app
[ -d /data/tmp/vrtheme/preload/symlink/system/app ] && preloadapps=1 || preloadapps=0
if [ "$preloadapps" -eq "1" ]; then
  busybox mkdir -p /data/tmp/vrtheme-backup/preload/symlink/system/app
  busybox mkdir -p /data/tmp/vrtheme/apply/preload/symlink/system/app/aligned
cd /data/tmp/vrtheme/preload/symlink/system/app
ui_print "   Processing /preload/symlink/system/app"
for f in $(ls)
do
	ui_print "     $f"
# get apk
  cp /preload/symlink/system/app/$f /data/tmp/vrtheme/apply/preload/symlink/system/app/
# backup apk
  cp /preload/symlink/system/app/$f /data/tmp/vrtheme-backup/preload/symlink/system/app/
# patch apk
  cd /data/tmp/vrtheme/preload/symlink/system/app/$f/
  /data/tmp/vrtheme/zip -r /data/tmp/vrtheme/apply/preload/symlink/system/app/$f *
# if classes.dex is included, delete dalvik-cache entry if it exists
	if [ -f classes.dex ]; then
		dc_file=/data/dalvik-cache$arm/system@app@$f@classes.dex
		dc_file_64=/data/dalvik-cache$arm64/system@app@$f@classes.dex
		if [ -f $dc_file ]; then
			rm -f $dc_file
			ui_print "       Old dalvik-cache entry deleted"
		fi
		if [ -f $dc_file_64 ]; then
			rm -f $dc_file_64
			ui_print "       Old dalvik-cache entry deleted"
		fi
	fi
# zipalign apk
	cd /data/tmp/vrtheme/apply/preload/symlink/system/app/
# busybox mkdir aligned
	/data/tmp/vrtheme/zipalign -f 4 $f aligned/$f
# move apk back
	cp aligned/$f /preload/symlink/system/app/
	chmod 644 /preload/symlink/system/app/$f
# symlink apk to \system\app
	ui_print "       Recreating symlink"
	rm -f /system/app/$f
	ln -s /preload/symlink/system/app/$f /system/app/$f
done
fi

# repeat for /system/framework
[ -d /data/tmp/vrtheme/system/framework ] && framework=1 || framework=0
if [ "$framework" -eq "1" ]; then
  busybox mkdir -p /data/tmp/vrtheme-backup/system/framework
	busybox mkdir -p /data/tmp/vrtheme/apply/system/framework/aligned
cd /data/tmp/vrtheme/system/framework
ui_print "   Processing /system/framework"
for f in $(ls)
do
	ui_print "     $f"
# get apk
  cp /system/framework/$f /data/tmp/vrtheme/apply/system/framework/
# backup apk
  cp /system/framework/$f /data/tmp/vrtheme-backup/system/framework/
# patch apk
  cd /data/tmp/vrtheme/system/framework/$f/
  /data/tmp/vrtheme/zip -r /data/tmp/vrtheme/apply/system/framework/$f *
# zipalign apk
	cd /data/tmp/vrtheme/apply/system/framework/
# busybox mkdir aligned
	/data/tmp/vrtheme/zipalign -f 4 $f aligned/$f
# move apk back
	cp aligned/$f /system/framework/
	chmod 644 /system/framework/$f
done
fi

# create restore zip from backup apks
datetime=$(busybox date +"%Y%m%d_%H%M%S")

if [ -d "/data/tmp/vrtheme-backup" ]; then
	ui_print "   Creating vrtheme-restore.zip"
	cd /data/tmp/vrtheme-backup/
  /data/tmp/vrtheme/zip -r /data/tmp/vrtheme/vrtheme_restore.zip *
    
    if [ ! -d "/sdcard/vrtheme-backup" ] then
        busybox mkdir -p /sdcard/vrtheme-backup
    fi
	
	mv /data/tmp/vrtheme/vrtheme_restore.zip /sdcard/vrtheme-backup/restore-$datetime.zip
	ui_print "   Restore zip created in /sdcard/vrtheme-backup"
fi

# cleanup work files
ui_print "   Cleaning up work files"
  rm -rf /data/tmp/
