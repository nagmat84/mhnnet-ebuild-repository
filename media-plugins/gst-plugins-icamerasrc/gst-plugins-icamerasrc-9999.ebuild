EAPI=8

inherit autotools git-r3 udev

DESCRIPTION="Intel IPU6 camera source for GStreamer"
HOMEPAGE="https://github.com/intel/icamerasrc"
EGIT_REPO_URI="https://github.com/intel/icamerasrc.git"
EGIT_BRANCH="icamerasrc_slim_api"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	x11-libs/libdrm
"
BDEPEND="
	virtual/pkgconfig
	sys-devel/autoconf
	sys-devel/automake
	sys-devel/libtool
	dev-util/cmake
	dev-vcs/git
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
	local mycmakeargs=(
	)
	econf
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
