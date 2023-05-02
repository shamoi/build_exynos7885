#!/bin/bash


vbmeta=$(pwd)/vbmeta/vbmeta.img
dev_list="a10 a20 a20e a30 a30s a40"
cd ~
mkdir recovery; cd recovery
git config --global color.ui true
git config --global user.name Shamoi
git config --global user.email darkskall@hotmail.com
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11
repo sync --force-sync -j$(($(nproc --all) + 1)) &>/dev/null || repo sync --force-sync -j$(($(nproc --all) + 1)) &>/dev/null
rm -rf .repo
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 15G


cp -f $vbmeta vbmeta.img

for dev in $dev_list; do
    rm -rf out
    git clone https://github.com/TWRP-exynos7885/android_device_samsung_${dev} device/samsung/${dev} --depth=1
    . build/envsetup.sh
    lunch twrp_${dev}-eng
    m recoveryimage
    if [ "$?" != "0" ]; then
        echo "Build for ${dev^} has failed!"
	exit 1
    fi
    img="$(pwd)/out/target/product/${dev}/recovery.img"
    img_md5=($(md5sum $img))
    new_img="twrp-${version}-${dev}-${today}.img"
    new_tar="twrp-${version}-${dev}-${today}.tar"
    cp -f $img $new_img
    cp -f $img recovery.img
    tar -cf $new_tar vbmeta.img recovery.img
    rm -f recovery.img


done
