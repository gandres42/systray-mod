sed -i 's/readonly property int smallIconSize: Kirigami\.Units\.iconSizes\.smallMedium/readonly property int smallIconSize: Kirigami.Units.iconSizes.small/' "./plasma-workspace/applets/systemtray/qml/main.qml"
mkdir plasma-workspace/build && cd plasma-workspace/build
cmake ..
make -j$(nproc)
cp cp plasma-workspace/build/bin/plasma/applets/org.kde.plasma.systemtray.so ./