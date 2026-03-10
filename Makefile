PLASMA_VERSION := $(shell dnf list --installed 2>/dev/null | grep plasma-workspace | head -1 | awk '{print $$2}' | cut -d'-' -f1)
SO_INSTALL    := /usr/lib64/qt6/plugins/plasma/applets/org.kde.plasma.systemtray.so
SO_BUILD      := plasma-workspace/build/bin/plasma/applets/org.kde.plasma.systemtray.so
MAIN_QML      := plasma-workspace/applets/systemtray/qml/main.qml

.PHONY: setup build install

setup:
	@if [ ! -d "plasma-workspace" ]; then \
		git clone https://invent.kde.org/plasma/plasma-workspace.git; \
	fi
	cd plasma-workspace && git fetch && git checkout v$(PLASMA_VERSION)

build:
	sed -i 's/readonly property int smallIconSize: Kirigami\.Units\.iconSizes\.smallMedium/readonly property int smallIconSize: Kirigami.Units.iconSizes.small/' "$(MAIN_QML)"
	podman build -t systray-build .
	podman run -it --rm -v "$(CURDIR)":/workspace:rw systray-build /bin/bash -c \
		"cd /workspace && \
		mkdir -p plasma-workspace/build && \
		cd plasma-workspace/build && \
		cmake .. && \
		make -j$$(nproc) org.kde.plasma.systemtray systemtrayplugin && \
		cd ../.. && \
		cp plasma-workspace/build/bin/plasma/applets/org.kde.plasma.systemtray.so ./"

install:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "This target must be run as root (use: sudo make install)"; \
		exit 1; \
	fi
	cp $(SO_INSTALL) ./org.kde.plasma.systemtray.so.bak
	cp $(SO_BUILD) $(SO_INSTALL)

clean:
	yes | podman system prune -a