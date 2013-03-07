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
KERNEL_SOURCE_DIR=${MAIN_DIR}/../baobab-kernel-aosp-s3
OUT_DIR=${MAIN_DIR}/baobab-kernel-out
BOOT_IMG_DIR=${MAIN_DIR}/boot-images
UPDATE_DIR=${MAIN_DIR}/cwm-update

# Compiling kernel
export ARCH=arm
export CROSS_COMPILE=${MAIN_DIR}/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-

(cd ${KERNEL_SOURCE_DIR} && make clean && make cyanogenmod_i9300_defconfig && make -j 4 && make modules)

mkdir -p ${OUT_DIR}

cp ${KERNEL_SOURCE_DIR}/arch/arm/boot/zImage ${OUT_DIR}/zImage
(cd ${KERNEL_SOURCE_DIR} && find . -name "*.ko" -exec cp {} ${OUT_DIR} \;)

# Extracting original boot image
(cd ${BOOT_IMG_DIR} && perl ../bin/split_bootimg.pl ${BOOT_IMG_DIR}/boot.img)

# Creating new boot image
(cd ${BOOT_IMG_DIR} && ../bin/mkbootimg --cmdline 'console=ttySAC2,115200' --kernel ${OUT_DIR}/zImage --ramdisk boot.img-ramdisk.gz -o baobab-boot.img)

cp ${BOOT_IMG_DIR}/baobab-boot.img ${UPDATE_DIR}

(cd ${UPDATE_DIR} && zip -r baobab-kernel.zip *)
