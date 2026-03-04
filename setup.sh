#!/bin/bash

if [ ! -d "plasma-workspace" ]; then
    git clone https://invent.kde.org/plasma/plasma-workspace.git
fi
PLASMA_VERSION=$(dnf list --installed | grep plasma-workspace | head -1 | awk '{print $2}' | cut -d'-' -f1)
cd plasma-workspace && git fetch && git checkout v$PLASMA_VERSION