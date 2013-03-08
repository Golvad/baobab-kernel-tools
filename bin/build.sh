#!/bin/bash

##
# Scripted process described at http://forum.xda-developers.com/showthread.php?t=1748297
#
# Prerequisites:
# * The kernel source location must be defined in KERNEL_SOURCE_DIR
# * Matching aosp boot image must exist in ../boot-images
#

cd `dirname $0`/..

MAIN_DIR=`pwd`
VERSION=0.2
KERNEL_SOURCE_DIR=${MAIN_DIR}/../baobab-kernel-aosp-s3
OUT_DIR=${MAIN_DIR}/baobab-kernel-out
BOOT_IMG_DIR=${MAIN_DIR}/boot-images
UPDATE_DIR=${MAIN_DIR}/cwm-update
MODULES_DIR=${UPDATE_DIR}/system/lib/modules/

# Compiling kernel
export ARCH=arm
export CROSS_COMPILE=${MAIN_DIR}/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-

(cd ${KERNEL_SOURCE_DIR} && make mrproper && make baobab_i9300_defconfig && make -j 4 && make modules) || exit $?

mkdir -p ${OUT_DIR}
mkdir -p ${MODULES_DIR}

(cp ${KERNEL_SOURCE_DIR}/arch/arm/boot/zImage ${OUT_DIR}/zImage) || exit $?
(cd ${KERNEL_SOURCE_DIR} && find . -name "*.ko" -exec cp {} ${MODULES_DIR} \;) || exit $?

# Extracting original boot image
(cd ${BOOT_IMG_DIR} && perl ../bin/split_bootimg.pl ${BOOT_IMG_DIR}/boot.img) || exit $?

# Creating new boot image
(cd ${BOOT_IMG_DIR} && ../bin/mkbootimg --cmdline 'console=ttySAC2,115200' --kernel ${OUT_DIR}/zImage --ramdisk boot.img-ramdisk.gz -o ${UPDATE_DIR}/boot.img) || exit $?

(cd ${UPDATE_DIR} && zip -r baobab-kernel_${VERSION}.zip *) || exit $?
