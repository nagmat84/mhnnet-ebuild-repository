EAPI=8

inherit autotools udev

DESCRIPTION="Intel IPU6 camera source for GStreamer (Arrow Lake)"
HOMEPAGE="https://github.com/intel/icamerasrc"
SRC_URI="https://github.com/intel/icamerasrc/archive/refs/tags/v${PV}-iot-arl-twl-asl-v6.12.tar.gz -> ${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="mirror"

BDEPEND="
	virtual/pkgconfig
	dev-build/autoconf
	dev-build/automake
	dev-build/libtool
"

DEPEND="
	acct-group/video
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/gst-plugins-bad:1.0
	media-libs/libva
	sys-firmware/ipu6-camera-bins-arl-twl-asl
	sys-libs/ipu6-camera-hal-arl-twl-asl
	x11-libs/libdrm
"

S="${WORKDIR}/icamerasrc-${PV}-iot-arl-twl-asl-v6.12"

RDEPEND="
	${DEPEND}
	!media-plugins/gst-plugins-icamerasrc-mtl-rpl
"

src_prepare() {
	export CHROME_SLIM_CAMHAL=ON
	export STRIP_VIRTUAL_CHANNEL_CAMHAL=ON
	export DEFAULT_CAMERA=0
	default
	eautoreconf
}

src_configure() {
	export CHROME_SLIM_CAMHAL=ON
	export STRIP_VIRTUAL_CHANNEL_CAMHAL=ON
	export DEFAULT_CAMERA=0
	econf --enable-gstdrmformat=yes
}

src_install() {
	default

	# Install udev rules file for camera devices
	udev_dorules "${FILESDIR}/70-ipu6-psys.rules"
}

pkg_postinst() {
	elog "Please note that you might need to adjust the DEFAULT_CAMERA variable"
	elog "based on your specific hardware setup. It is currently set to: ${DEFAULT_CAMERA}"
}
