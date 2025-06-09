EAPI=8

inherit systemd udev user-info

DESCRIPTION="Citrix Workspace App"
HOMEPAGE="https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html"

SRC_URI="https://downloads.citrix.com/23334/linuxx64-${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"

LICENSE="citrix-eula"
SLOT="0"

RESTRICT="fetch mirror"

IUSE="apparmor app-protection chrome device-trust gnome gstreamer microsoft-edge systemd sysv-utils usb"

# See
# https://docs.citrix.com/en-us/citrix-workspace-app-for-linux/system-requirements.html
# for a list of required libraries
DEPEND="
	!!<${CATEGORY}/${PF}[apparmor]
	app-crypt/libsecret
	dev-libs/json-c
	dev-libs/libtar
	dev-libs/libxml2
	dev-libs/openssl
	dev-libs/xerces-c
	gui-libs/gtk[cloudproviders]
	media-libs/alsa-lib
	media-libs/libpulse
	media-libs/libvorbis
	media-libs/speexdsp
	>=media-libs/libva-2
	net-libs/libnsl
	net-libs/webkit-gtk:4/37
	>=sys-libs/glibc-2.27
	sys-libs/libcap
	sys-libs/zlib
	virtual/udev
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
	apparmor?   ( sys-libs/libapparmor )
	gnome?      ( gnome-base/gnome-shell )
	gstreamer?  ( media-libs/gstreamer:1.0 )
	systemd?    ( sys-apps/systemd[apparmor=] )
	sysv-utils? ( sys-apps/openrc )
"

RDEPEND="
	${DEPEND}
"

pkg_nofetch() {
	einfo "Please download"
	einfo "    linuxx64-${PV}.tar.gz"
	einfo "from"
	einfo "    ${HOMEPAGE}"
	einfo "and place them in your DISTDIR as"
	einfo "    ${P}.tar.gz"
}
