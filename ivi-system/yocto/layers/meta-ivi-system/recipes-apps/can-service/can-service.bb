SUMMARY = "CAN Service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://can-service"

S = "${WORKDIR}/can-service"

DEPENDS = "vsomeip boost"

inherit cmake

# Assume the source code is copied into the build directory or fetched via git
# For this structure, we point to local files if we were using 'devtool', 
# but in a real repo we would point to a git repo.
# Here we assume the source is provided in the layer's 'files' directory or similar workspace.
