FROM fedora:43

ARG USERNAME=USERNAME
ARG CONTAINER_ID=CONTAINER_ID
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN dnf install -y sudo passwd util-linux-user procps-ng ncurses
RUN dnf upgrade --refresh -y
RUN dnf clean all

# Create non-root user and add to sudo
RUN if id -u $USER_UID &>/dev/null; then userdel -r $(id -un $USER_UID); fi \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN dnf builddep -y plasma-workspace-devel
RUN ln -sf /usr/libexec /usr/lib64/libexec

# setup home env
RUN chsh -s /bin/bash $USERNAME
USER $USERNAME
RUN echo "source /home/$USERNAME/.dotfiles/setup.bash" >> /home/$USERNAME/.bashrc
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/$USERNAME/.bashrc
ENV CONTAINER_ID $CONTAINER_ID
