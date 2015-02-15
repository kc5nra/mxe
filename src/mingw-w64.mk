# This file is part of MXE.
# See index.html for further information.

PKG             := mingw-w64
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.0-rc2
$(PKG)_CHECKSUM := 6f046e495d5eac0560e7585c58cb801d932e85fa
$(PKG)_SUBDIR   := $(PKG)-v$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-v$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := http://$(SOURCEFORGE_MIRROR)/project/$(PKG)/$(PKG)/$(PKG)-release/$($(PKG)_FILE)
$(PKG)_DEPS     := widl

define $(PKG)_UPDATE
    git ls-remote --tags git://git.code.sf.net/p/mingw-w64/mingw-w64 | \
    cut -d '/' -f 3 | \
    cut -d '^' -f 1 | \
    cut -c 2- | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD_mingw-w64
    mkdir '$(1).headers-build'
    cd '$(1).headers-build' && '$(1)/mingw-w64-headers/configure' \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --enable-sdk=all \
        --enable-secure-api \
        --enable-idl \
        --with-widl

#    $(MAKE) -C '$(1).headers-build' install
#    cd ..
#    mkdir '$(1).crt-build'
#    cd '$(1).crt-build' && '$(1)/mingw-w64-crt/configure' \
#        --host='$(TARGET)' \
#        --prefix='$(PREFIX)/$(TARGET)'

   
endef

$(PKG)_BUILD_x86_64-w64-mingw32 = $($(PKG)_BUILD_mingw-w64)
$(PKG)_BUILD_i686-w64-mingw32   = $($(PKG)_BUILD_mingw-w64)
