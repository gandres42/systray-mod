# Native build (no container). Run on a Fedora host with KDE Plasma.
# Usage:
#   sudo make -f Makefile.native deps     # install build dependencies (once)
#        make -f Makefile.native setup     # clone plasma-workspace at your version
#        make -f Makefile.native build     # patch + build the applet natively
#   sudo make -f Makefile.native install   # back up and install the built .so

PLASMA_VERSION := $(shell dnf list --installed 2>/dev/null | grep plasma-workspace | head -1 | awk '{print $$2}' | cut -d'-' -f1)
SO_INSTALL    := /usr/lib64/qt6/plugins/plasma/applets/org.kde.plasma.systemtray.so
SO_BUILD      := plasma-workspace/build/bin/plasma/applets/org.kde.plasma.systemtray.so
MAIN_QML      := plasma-workspace/applets/systemtray/qml/main.qml

.PHONY: deps setup build install clean

build:
	rm -rf plasma-workspace
	git clone https://invent.kde.org/plasma/plasma-workspace.git
	cd plasma-workspace && git fetch && git checkout v$(PLASMA_VERSION)
	sed -i 's/readonly property int smallIconSize: Kirigami\.Units\.iconSizes\.smallMedium/readonly property int smallIconSize: Kirigami.Units.iconSizes.small/' "$(MAIN_QML)"
	mkdir -p plasma-workspace/build 
	cd plasma-workspace/build && \
		cmake .. && \
		make -j$$(nproc) org.kde.plasma.systemtray systemtrayplugin
	cp $(SO_BUILD) ./

deps:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "This target must be run as root (use: sudo make -f Makefile.native deps)"; \
		exit 1; \
	fi
	dnf builddep -y plasma-workspace-devel
	ln -sf /usr/libexec /usr/lib64/libexec

install:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "This target must be run as root (use: sudo make -f Makefile.native install)"; \
		exit 1; \
	fi
	cp $(SO_INSTALL) ./org.kde.plasma.systemtray.so.bak
	cp $(SO_BUILD) $(SO_INSTALL)

clean:
	rm -rf plasma-workspace/build
