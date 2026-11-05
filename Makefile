# Native build (no container). Run on an openSUSE Tumbleweed host with KDE Plasma.
# Usage:
#   sudo make deps     # install build dependencies (once)
#        make build    # clone plasma-workspace at your version, patch + build the applet
#   sudo make install  # back up and install the built .so

PLASMA_VERSION := $(shell rpm -q --qf '%{VERSION}' plasma6-workspace 2>/dev/null)
SRC_REPO      := repo-source
SO_INSTALL    := /usr/lib64/qt6/plugins/plasma/applets/org.kde.plasma.systemtray.so
SO_BUILD      := plasma-workspace/build/bin/plasma/applets/org.kde.plasma.systemtray.so
MAIN_QML      := plasma-workspace/applets/systemtray/qml/main.qml

.PHONY: deps build install clean

build:
	rm -rf plasma-workspace
	git clone https://invent.kde.org/plasma/plasma-workspace.git
	cd plasma-workspace && git fetch && git checkout v$(PLASMA_VERSION)
	sed -i 's/readonly property int smallIconSize: Kirigami\.Units\.iconSizes\.smallMedium/readonly property int smallIconSize: Kirigami.Units.iconSizes.small/' "$(MAIN_QML)"
	mkdir -p plasma-workspace/build 
	cd plasma-workspace/build && \
		cmake -DBUILD_TESTING=OFF .. && \
		make -j$$(nproc) org.kde.plasma.systemtray systemtrayplugin
	cp $(SO_BUILD) ./

deps:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "This target must be run as root (use: sudo make deps)"; \
		exit 1; \
	fi
	zypper -n in git cmake gcc-c++
	@# zypper source-install needs the source repo; enable it only for this step
	@if zypper -x lr $(SRC_REPO) | grep -q 'enabled="1"'; then \
		zypper -n --gpg-auto-import-keys si -d plasma6-workspace; \
	else \
		zypper mr -e $(SRC_REPO) && \
		zypper -n --gpg-auto-import-keys ref $(SRC_REPO) && \
		zypper -n --gpg-auto-import-keys si -d plasma6-workspace; \
		ret=$$?; zypper mr -d $(SRC_REPO); exit $$ret; \
	fi

install:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "This target must be run as root (use: sudo make install)"; \
		exit 1; \
	fi
	cp $(SO_INSTALL) ./org.kde.plasma.systemtray.so.bak
	cp $(SO_BUILD) $(SO_INSTALL)

clean:
	rm -rf plasma-workspace/build
