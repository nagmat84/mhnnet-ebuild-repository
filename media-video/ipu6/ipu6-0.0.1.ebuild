EAPI=8

DESCRIPTION="Meta-package and config files for IPU6 support"
HOMEPAGE="https://github.com/nagmat84/mhnnet-ebuild-repository"

LICENSE="GPL-3"

SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	virtual/gst-plugins-icamerasrc
	virtual/ipu6-camera-bins
	virtual/ipu6-camera-hal
	media-video/pipewire[libcamera]
	media-libs/libcamera[gstreamer]
"

S="${FILESDIR}"

src_install() {
	insinto /etc/wireplumber/wireplumber.conf.d/
	doins disable-v4l2-and-prefer-libcamera.conf
}
