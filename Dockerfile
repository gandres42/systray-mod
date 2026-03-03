FROM fedora:43
RUN dnf install -y sudo passwd util-linux-user procps-ng ncurses xdotool
RUN dnf upgrade --refresh -y
RUN dnf builddep -y plasma-workspace-devel
RUN ln -sf /usr/libexec /usr/lib64/libexec
