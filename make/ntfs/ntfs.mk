PACKAGE_LC:=ntfs
PACKAGE_UC:=NTFS
$(PACKAGE_UC)_VERSION:=1.1004
$(PACKAGE_INIT_BIN)
NTFS_SOURCE:=ntfs-3g-$(NTFS_VERSION).tgz
NTFS_SITE:=http://www.ntfs-3g.org/
NTFS_DIR:=$(SOURCE_DIR)/ntfs-3g-$(NTFS_VERSION)
NTFS_BINARY:=$(NTFS_DIR)/src/ntfs-3g
NTFS_TARGET_BINARY:=$(NTFS_DEST_DIR)/usr/bin/ntfs-3g
NTFS_STARTLEVEL=30

$(PACKAGE_UC)_CONFIGURE_ENV += FUSE_MODULE_CFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include/fuse"
$(PACKAGE_UC)_CONFIGURE_ENV += FUSE_MODULE_LIBS="-pthread -lfuse -ldl"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(NTFS_DIR) all \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" 

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

ntfs: uclibc fuse $($(PACKAGE_UC)_TARGET_BINARY)

ntfs-precompiled: fuse-precompiled ntfs $($(PACKAGE_UC)_TARGET_BINARY)

ntfs-clean:
	-$(MAKE) -C $(NTFS_DIR) clean

ntfs-uninstall:
	rm -f $(NTFS_TARGET_BINARY)

$(PACKAGE_FINI)
