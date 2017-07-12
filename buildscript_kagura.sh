make mrproper
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache-kagura
export ARCH=arm64
export PATH=../aarch64-linux-android-4.9/bin:$PATH
export CROSS_COMPILE=aarch64-linux-android-
make kagura-rytek_defconfig |& tee log_generic.txt
make -j$(grep -c ^processor /proc/cpuinfo) |& tee -a log_generic.txt

echo "checking for compiled kernel..."
if [ -f arch/arm64/boot/Image.gz-dtb ]
then

	echo "DONE"
	rm -f ../final_files/boot_kagura.img

	../final_files/mkbootimg \
	--kernel arch/arm64/boot/Image.gz-dtb \
	--ramdisk ../final_files/newrd.gz \
	--cmdline "androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 cma=16M@0-0xffffffff coherent_pool=2M" \
	--base 0x80000000 \
	--pagesize 4096 \
	--ramdisk_offset 0x02200000 \
	--tags_offset 0x02000000 \
	--output ../final_files/boot_kagura.img

	cd ../final_files/

	if [ -e boot_kagura.img ]
	then
		cp boot_kagura.img boot.img
		zip RyTek_Kernel.zip boot.img
		rm -f boot.img
	fi
fi
