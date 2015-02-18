# This file is part of MXE.
# See index.html for further information.

PKG             := qtbase
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.4.0
$(PKG)_CHECKSUM := 2e3d32f32e36a92782ca66c260940824746900bd
$(PKG)_SUBDIR   := $(PKG)-opensource-src-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-opensource-src-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := http://download.qt-project.org/official_releases/qt/5.4/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc 

define $(PKG)_UPDATE
    $(WGET) -q -O- http://download.qt-project.org/official_releases/qt/5.1/ | \
    $(SED) -n 's,.*href="\(5\.[0-9]\.[^/]*\)/".*,\1,p' | \
    grep -iv -- '-rc' | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(1)' && \
        ./configure \
            -DQT_NO_SESSIONMANAGER \
            -opensource \
            -confirm-license \
            -xplatform win32-g++ \
            -device-option CROSS_COMPILE=${TARGET}- \
            -device-option PKG_CONFIG='${TARGET}-pkg-config' \
            -force-pkg-config \
            -prefix '$(PREFIX)/$(TARGET)/qt5' \
            -release \
            -static \
            -nomake examples \
            -nomake tests \
            -no-compile-examples \
            -no-feature-style-plastique \
            -no-feature-style-cleanlooks \
            -no-feature-style-motif \
            -no-feature-style-cde \
            -no-feature-style-windowsce \
            -no-feature-style-windowsmobile \
            -no-feature-style-s60 \
            -opengl desktop \
            -qt-libpng \
            -qt-pcre \
            -qt-zlib \
            -no-dbus \
            -no-freetype \
            -no-glib \
            -no-icu \
            -no-harfbuzz \
            -no-nis \
            -no-opengl \
            -no-openssl \
            -no-pch \
            -no-qml-debug \
            -no-sm \
            -no-sql-mysql \
            -no-sql-odbc \
            -no-sql-psql \
            -no-sql-sqlite \
            -no-sql-tds \
            -no-gif \
            -no-libjpeg \
            -v

    # invoke qmake with removed debug options as a workaround for
    # https://bugreports.qt-project.org/browse/QTBUG-30898
    $(MAKE) -C '$(1)' -j '$(JOBS)' QMAKE="$(1)/bin/qmake CONFIG-='debug debug_and_release'"
    rm -rf '$(PREFIX)/$(TARGET)/qt5'
    $(MAKE) -C '$(1)' -j 1 install
    ln -sf '$(PREFIX)/$(TARGET)/qt5/bin/qmake' '$(PREFIX)/bin/$(TARGET)'-qmake-qt5

    mkdir            '$(1)/test-qt'
    cd               '$(1)/test-qt' && '$(PREFIX)/$(TARGET)/qt5/bin/qmake' '$(PWD)/src/qt-test.pro'
    $(MAKE)       -C '$(1)/test-qt' -j '$(JOBS)'
    $(INSTALL) -m755 '$(1)/test-qt/release/test-qt5.exe' '$(PREFIX)/$(TARGET)/bin/'

    # build test the manual way
    mkdir '$(1)/test-$(PKG)-pkgconfig'
    '$(PREFIX)/$(TARGET)/qt5/bin/uic' -o '$(1)/test-$(PKG)-pkgconfig/ui_qt-test.h' '$(TOP_DIR)/src/qt-test.ui'
    '$(TARGET)-g++' \
        -W -Wall -Werror -std=c++0x -pedantic \
        '$(TOP_DIR)/src/qt-test.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG)-pkgconfig.exe' \
        -I'$(1)/test-$(PKG)-pkgconfig' \
        `'$(TARGET)-pkg-config' Qt5Widgets --cflags --libs`

    # batch file to run test programs
    (printf 'set PATH=..\\lib;..\\qt5\\bin;..\\qt5\\lib;%%PATH%%\r\n'; \
     printf 'set QT_QPA_PLATFORM_PLUGIN_PATH=..\\qt5\\plugins\r\n'; \
     printf 'test-qt5.exe\r\n'; \
     printf 'test-qtbase-pkgconfig.exe\r\n';) \
     > '$(PREFIX)/$(TARGET)/bin/test-qt5.bat'
endef


$(PKG)_BUILD_SHARED = $(subst -static ,-shared ,\
                      $($(PKG)_BUILD))
