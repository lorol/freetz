TOOLCHAIN_HOSTCC:=gcc
TOOLCHAIN_HOST_CFLAGS:=
ifeq ($(strip $(FREETZ_TOOLCHAIN_MINIMIZE_REQUIRED_GLIBC_VERSION)),y)

# avoids dependency on __isoc99_sscanf@@GLIBC_2.7 (added in GLIBC 2.7)
TOOLCHAIN_HOST_CFLAGS+=-D_GNU_SOURCE

# avoids dependency on __stack_chk_fail@@GLIBC_2.4 (added in GLIBC 2.4)
TOOLCHAIN_HOST_CFLAGS+=-fno-stack-protector

endif

ifeq ($(strip $(FREETZ_TOOLCHAIN_32BIT)),y)
TOOLCHAIN_HOST_CFLAGS+=-m32
endif

ifeq ($(strip $(FREETZ_KERNEL_GCC_3_4)),y)
KERNEL_TOOLCHAIN_NO_MPFR:=y
endif



BINUTILS_BINARIES_BIN := addr2line ar as c++filt elfedit gprof ld nm objcopy objdump ranlib readelf size strings strip
GCC_BINARIES_BIN := gcc g++ cc c++ cpp gcov
GCC_BINARIES_LIBEXEC := cc1 cc1plus collect2 liblto_plugin.so.0.0.0 lto-wrapper lto1 install-tools/fixincl

# $1 - toolchain base dir
# $2 - binaries
# $3 - target name
define TOOLCHAIN_BINARIES_LIST
	$(addprefix $(1),$(foreach p,/bin/ /bin/$(3)- /$(3)/bin/,$(foreach b,$(2),$(p)$(b))))
endef

# $1 - toolchain base dir
# $2 - binaries
# $3 - target name
# $4 - strip command to be used
define STRIP_TOOLCHAIN_BINARIES
	-$(4) $(call TOOLCHAIN_BINARIES_LIST,$(1),$(2),$(3)) >/dev/null 2>&1
endef

# $1 - toolchain base dir
# $2 - gcc version
# $3 - target name
# $4 - strip command to be used
define STRIP_GCC_LIBEXEC_BINARIES
	-$(4) $(addprefix $(1)/libexec/gcc/$(3)/$(2)/,$(GCC_BINARIES_LIBEXEC)) >/dev/null 2>&1
endef

# $1 - toolchain base dir
# $2 - target name
define GCC_ENSURE_CC_CXX
	# make sure we have '*cc' && '*c++' / replace identical files and hardlinks with symlinks
	for d in "$(1)/bin" "$(1)/$(2)/bin"; do \
		for p in "" $(2)-; do \
			pp="$${d}/$${p}"; \
			if [ -f "$${pp}gcc" ]; then \
				ln -snf $${p}gcc $${pp}cc; \
			fi; \
			if [ -f "$${pp}g++" ]; then \
				ln -snf $${p}g++ $${pp}c++; \
			fi; \
		done; \
	done;
endef

# $1 - toolchain base dir
# $2 - gcc version
# $3 - target name
# $4 - strip command to be used
define GCC_INSTALL_COMMON
	$(RM) $(1)/bin/*-$(2) # remove unnecessary *-$(GCC_VERSION) files
	$(call STRIP_TOOLCHAIN_BINARIES,$(1),$(GCC_BINARIES_BIN),$(3),$(4))
	$(call STRIP_GCC_LIBEXEC_BINARIES,$(1),$(2),$(3),$(4))
	$(call GCC_ENSURE_CC_CXX,$(1),$(3))
endef

# $1 - toolchain base dir
# $2 - binaries
# $3 - real target name
# $4 - target name
define CREATE_TARGET_NAME_SYMLINKS
	for app in $(2); do \
		if [ -e $(1)/bin/$(3)-$${app} ]; then \
			ln -snf $(3)-$${app} $(1)/bin/$(4)-$${app}; \
		fi; \
	done;
endef

define updir
$(patsubst %/,%,$(dir $(patsubst %/,%,$(strip $(1)))))
endef


TOOLCHAIN_EXCLUDE_FILES := *uClibc++* *g++-uc *g++-wrapper* libtool* aclocal lib32
# Union of versions 2.6.13, 2.6.19, and 2.6.28
KERNEL_HEADERS_SUBDIRS := asm asm-generic drm linux mtd rdma scsi sound video

# $1 - toolchain base dir
# $2 - tarball name suffix (TARGET_ARCH? / toolchain version)
define TOOLCHAIN_CREATE_TARBALL
	droot="$(call updir,$(call updir,$(1)))"; \
	dname="$(notdir $(call updir,$(1)))"; \
	tname="$${dname}$(if $(strip $(2)),-$(strip $(2)))"; \
	$(RM) $(DL_DIR)/$${tname}.tar.lzma; \
	$(TOOLS_DIR)/tar -C $${droot} -c $${dname} $(foreach f,$(TOOLCHAIN_EXCLUDE_FILES) $(addprefix include/,$(KERNEL_HEADERS_SUBDIRS)),--exclude $(f)) | \
	$(TOOLS_DIR)/lzma e -si $(DL_DIR)/$${tname}.tar.lzma -d25;
endef

# $1 - source dir
# $2 - target dir
# $3 - subdirs to be copied (optional, if omitted all subdirs are copied)
define COPY_KERNEL_HEADERS
	if ! diff -q $(strip $(1))/include/linux/version.h $(strip $(2))/include/linux/version.h >/dev/null 2>&1 ; then \
		$(RM) -r $(addprefix $(strip $(2))/include/,$(KERNEL_HEADERS_SUBDIRS)); \
		mkdir -p $(strip $(2))/include/; \
		cp -pLR $(strip $(1))/include/$(if $(strip $(3)),$(strip $(3)),*) $(strip $(2))/include/; \
	fi;
endef

# FIXME: define only once
# PKG_EDIT_CONFIG
# update a config file
#   $(1) = list of assignments CONFIG_VAR=value
PKG_EDIT_CONFIG__INT0 = -e 's%^(\# )?($1)[ =].*%$(if $(patsubst n,,$2),\2=$2,\# \2 is not set)%g'
PKG_EDIT_CONFIG__INT1 = $(call PKG_EDIT_CONFIG__INT0,$(word 1,$(subst =, ,$1)),$(word 2,$(subst =, ,$1)))
PKG_EDIT_CONFIG = $(SED) -i -r $(foreach asg,$1,$(call PKG_EDIT_CONFIG__INT1,$(asg)))