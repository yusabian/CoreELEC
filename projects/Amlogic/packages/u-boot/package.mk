# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2017-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="u-boot"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_DEPENDS_TARGET="toolchain gcc-linaro-aarch64-elf:host gcc-linaro-arm-eabi:host"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

if [ "$DEVICE" = "S905" ];then
    PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET u-boot-Odroid_C2 u-boot-LePotato u-boot-KVIM"
    PKG_SUBDEVICES="Odroid_C2 LePotato KVIM"
elif [ "$DEVICE" = S912 ];then
    PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET u-boot-KVIM2"
    PKG_SUBDEVICES="KVIM2"
fi

PKG_CANUPDATE="${DEVICE}*"
PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader"
[ -n "$SUBDEVICE" ] && PKG_NEED_UNPACK+=" $PROJECT_DIR/$PROJECT/devices/$DEVICE/bootloader"

make_target() {
    : # nothing
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

    # Always install the update script
    find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    sed -e "s/@KERNEL_NAME@/$KERNEL_NAME/g" \
        -e "s/@LEGACY_KERNEL_NAME@/$LEGACY_KERNEL_NAME/g" \
        -i $INSTALL/usr/share/bootloader/update.sh

    # Always install the canupdate script
    if find_file_path bootloader/canupdate.sh; then
      cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    fi

    for PKG_DEVICE in $PKG_SUBDEVICES;do
        find_file_path bootloader/${PKG_DEVICE}_boot.ini && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
        find_file_path bootloader/${PKG_DEVICE}_config.ini && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
	if [ $PKG_DEVICE = "Odroid_C2" ]; then
            PKG_UBOOTBIN=$(get_build_dir u-boot-${PKG_DEVICE})/u-boot.bin
	else
            PKG_UBOOTBIN=$(get_build_dir u-boot-${PKG_DEVICE})/fip/u-boot.bin.sd.bin
	fi
        cp -av ${PKG_UBOOTBIN} $INSTALL/usr/share/bootloader/${PKG_DEVICE}_u-boot
	PKG_CANUPDATE+="|${PKG_DEVICE}*"
    done
      sed -e "s/@PROJECT@/${PKG_CANUPDATE}/g" \
          -i $INSTALL/usr/share/bootloader/canupdate.sh
    find_file_path splash/boot-logo.bmp.gz && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
}
