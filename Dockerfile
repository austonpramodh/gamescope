FROM fedora:39 AS builder

WORKDIR /gamescope

# Install git
RUN sudo dnf install -y git

# clone the repository
RUN git clone https://github.com/austonpramodh/gamescope.git /gamescope

RUN git submodule update --init

RUN git clone https://github.com/vcrhonek/hwdata.git

# Install the required packages

RUN sudo dnf install -y gcc-c++

RUN sudo dnf install -y meson ninja-build cmake

# Configure HWData

RUN cd hwdata && ./configure 

RUN cd hwdata && make

RUN cd hwdata && sudo make install


# Install the required packages

RUN sudo dnf -y install libX11-devel wayland-devel vulkan-loader-devel wayland-protocols-devel libXdamage-devel \
    libXcomposite-devel libXcursor-devel libXext-devel libXxf86vm-devel libXtst-devel libXres-devel libXmu-devel libdrm-devel \
    rust-xkbcommon-devel pixman-devel rust-libudev-devel wlroots-devel xorg-x11-server-Xwayland-devel glslang libcap-devel

# Build and install gamescope
RUN meson build

COPY ./patches/001-conditional-libvavif-fix.patch /gamescope/patches/001-conditional-libvavif-fix.patch

RUN git apply /gamescope/patches/001-conditional-libvavif-fix.patch

RUN ninja -C build


FROM scratch AS gamescope-bin
COPY --from=builder /gamescope/build/src/gamescope /bin/gamescope
ENTRYPOINT [ "/bin/gamescope" ]
