
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

cp /usr/lib64/qt6/plugins/plasma/applets/org.kde.plasma.systemtray.so ./org.kde.plasma.systemtray.so.bak
cp plasma-workspace/build/bin/plasma/applets/org.kde.plasma.systemtray.so /usr/lib64/qt6/plugins/plasma/applets/