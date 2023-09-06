FROM archlinux/archlinux

WORKDIR /home/workspace

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm flex bison make vim