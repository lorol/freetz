$(call PKG_INIT_BIN, 0.2)
$(PKG)_SOURCE:=matrixtunnel-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=af169751efc7d87d500716a48d74ddc5
$(PKG)_SITE:=http://znerol.ch/files/OLDSTUFF-PLEASE-DONT-USE
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/matrixtunnel

$(PKG)_BINARY:=$($(PKG)_DIR)/src/matrixtunnel
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/matrixtunnel

$(PKG)_DEPENDS_ON += matrixssl

$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_MATRIXTUNNEL_STATIC),--enable-semistatic)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MATRIXTUNNEL_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MATRIXTUNNEL_STATIC_FULL

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MATRIXTUNNEL_DIR)/src \
		EXTRA_CFLAGS="-ffunction-sections -fdata-sections" \
		EXTRA_LDFLAGS="-Wl,--gc-sections $(if $(FREETZ_PACKAGE_MATRIXTUNNEL_STATIC_FULL),-static)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MATRIXTUNNEL_DIR)/src clean

$(pkg)-uninstall:
	$(RM) $(MATRIXTUNNEL_TARGET_BINARY)

$(PKG_FINISH)
