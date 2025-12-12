SUMMARY = "IVI System Image"
LICENSE = "MIT"

IMAGE_FEATURES += "splash ssh-server-openssh package-management hwcodecs"

inherit core-image

IMAGE_INSTALL:append = " \
    packagegroup-core-boot \
    packagegroup-core-full-cmdline \
    qtbase \
    qtdeclarative \
    qtdeclarative-quick \
    qtmultimedia \
    qtwayland \
    vsomeip \
    can-utils \
    iproute2 \
    gstreamer1.0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    can-service \
    pdc-service \
    media-service \
    cluster-ui \
"

# Auto-start services
IMAGE_INSTALL:append = " ivi-system-init"
