EAPI=8

inherit meson

DESCRIPTION="A complex camera support library for Linux, Android, and ChromeOS"
HOMEPAGE="https://libcamera.org/"

SRC_URI="https://github.com/libcamera-org/libcamera/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

LICENSE="LGPL-2.1+"
SLOT="0"

RESTRICT="mirror"

IUSE="debug drm gnutls gstreamer jpeg libevent libyuv python qt6 sdl tiff trace udev unwind v4l2"

BDEPEND="|| ( net-libs/gnutls dev-libs/openssl )"

DEPEND="
	dev-libs/libyaml:=
	dev-python/jinja2
	dev-python/ply
	dev-python/pyyaml
	debug? ( dev-libs/elfutils:= )
	gstreamer? ( media-libs/gstreamer:= )
	libevent?
	(
		dev-libs/libevent:=
		drm? ( x11-libs/libdrm:= )
		jpeg? ( media-libs/libjpeg-turbo:= )
		sdl? ( media-libs/libsdl2:= )
		tiff? ( media-libs/tiff:= )
	)
	libyuv? ( media-libs/libyuv )
	qt6?
	(
		dev-qt/qtbase:6
		media-libs/tiff:=
	)
	trace? ( dev-util/lttng-ust:= )
	udev? ( virtual/libudev:= )
	unwind? ( sys-libs/libunwind:= )
"
RDEPEND="
	${DEPEND}
	trace? ( dev-util/lttng-tools )
"
src_configure() {
	local emesonargs=(
		-Ddocumentation=disabled
		$(meson_feature libevent cam)
		$(meson_feature gstreamer)
		$(meson_feature qt6 qcam)
		$(meson_feature python pycamera)
		$(meson_feature trace tracing)
		$(meson_feature v4l2)
		"-Dipas=ipu3,simple"
		"-Dpipelines=auto"
	)

	meson_src_configure
}
