# This file is part of MXE.
# See index.html for further information.

PKG             := mingw-w64
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4fd76bd
$(PKG)_CHECKSUM := 85e47e3ef27e1cee918e51846d4477a61332d308
$(PKG)_SUBDIR   := mirror-$(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://github.com/mirror/$(PKG)/tarball/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := widl

$(PKG)_UPDATE = $(call MXE_GET_GITHUB_SHA, mirror/mingw-w64, master)

define $(PKG)_BUILD_mingw-w64
    mkdir '$(1).headers-build'
    cd '$(1).headers-build' && '$(1)/mingw-w64-headers/configure' \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --enable-sdk=all \
        --enable-secure-api \
        --enable-idl \
        --with-widl

    $(MAKE) -C '$(1).headers-build' install
   
endef

$(PKG)_BUILD_x86_64-w64-mingw32 = $($(PKG)_BUILD_mingw-w64)
$(PKG)_BUILD_i686-w64-mingw32   = $($(PKG)_BUILD_mingw-w64)
