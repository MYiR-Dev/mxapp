通过yocto直接从github上下载MXAPP源码并进行编译，在sources/meta-myir/meta-bsp/recipes-myir中软件hmi目录，并在目录当中添加hmi_1.0.bb文件，hmi_1.0.bb文件内容如下所示：

SUMMARY = "MYIR HMI Demo Experience"
DESCRIPTION = "Launcher for MYIR HMI Demo"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

S = "${WORKDIR}/git"

SRCBRANCH = "MXAPP2-Qt5"

MYIR_HMI_SRC ?= "git://github.com/xmr123456/MXAPP2.git;protocol=https"

SRC_URI = " \
    ${MYIR_HMI_SRC};branch=${SRCBRANCH} \
     "


SRCREV = "256bf6f0ae2a88836f7eec743c75ce0bcd89a4cc"

#SRCREV_FORMAT = "myir-hmi-demos"
#SRCREV_myir-hmi-demos = "256bf6f0ae2a88836f7eec743c75ce0bcd89a4cc"
#SRC_URI[myir-hmi-demos.sha256sum] = "37abc8215473ccaed8afb7b515b9cf17ba6e25c4a49188b55762bd7c1aa58ed9"

inherit qmake5

DEPENDS += " packagegroup-qt5-imx qtquickcontrols2 qtconnectivity qtgraphicaleffects qtsvg qtmultimedia "
RDEPENDS_${PN} += " weston bash qtgraphicaleffects-qmlplugins qtquickcontrols-qmlplugins qtsvg-plugins"

do_install() {
    install -d -m 755 ${D}/home/root/

    
    install ${WORKDIR}/build/mxapp2 ${D}/home/root/
}

FILES_${PN} += "/home/root/mxapp2 "