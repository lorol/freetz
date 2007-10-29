PACKAGE_LC:=deco
PACKAGE_UC:=DECO
$(PACKAGE_UC)_VERSION:=39
$(PACKAGE_INIT_BIN)
DECO_SOURCE:=deco$(DECO_VERSION).tgz
DECO_SITE:=http://mesh.dl.sourceforge.net/sourceforge/deco
DECO_DIR:=$(SOURCE_DIR)/deco$(DECO_VERSION)
DECO_BINARY:=$(DECO_DIR)/deco
DECO_TARGET_BINARY:=$(DECO_DEST_DIR)/usr/bin/deco

$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += autoconf --force ;


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(DECO_DIR)

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

deco:

deco-precompiled: uclibc ncurses-precompiled deco $($(PACKAGE_UC)_TARGET_BINARY)

deco-clean:
	-$(MAKE) -C $(DECO_DIR) clean

deco-uninstall:
	rm -f $(DECO_TARGET_BINARY)

$(PACKAGE_FINI)
