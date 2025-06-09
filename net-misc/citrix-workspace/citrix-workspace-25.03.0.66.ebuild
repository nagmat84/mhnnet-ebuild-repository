EAPI=8

inherit systemd udev user-info

DESCRIPTION="Citrix Workspace App"
HOMEPAGE="https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html"

SRC_URI="https://downloads.citrix.com/23334/linuxx64-${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"

LICENSE="citrix-eula"
SLOT="0"

RESTRICT="fetch mirror"

#
# apparmor -       Installs AppArmor profiles for Citrix Enterprise Browser.
#                  The use flag is currently masked, because it is not
#                  implemented and I have no way to test it.
#                  This use flags serves as a reminder that this feature
#                  exist.
#                  See `create_apparmor_profile_if_required()` of the
#                  upstream setup script for references if you want to add
#                  this feature.
#
# app-protection - Installs the App Protection component.
#                  The use flag is currently masked.
#                  App Protection is a feature which shall prevent the user
#                  from performing certain "forbidden" actions like taking
#                  screenshots, copying/moving files, modifying the Citrix
#                  package itself, etc.
#                  It works via pre-loading a share object file
#                  (AppProtection.so) at a very early boot stage which
#                  catches library calls and either let them fail or relay
#                  the library call to the actual library.
#                  This feature does not work properly on Gentoo.
#                  In particular, it makes xwayland-video-bridge utilizing
#                  100% CPU on a single core and it interferes with the
#                  normal Gentoo package management as AppProtection.so -
#                  after it has been installed once - tries to prevent
#                  changes to the Citrix installation.
#                  This use flags serves as a reminder that this feature
#                  exist.
#
# chrome         - Installs the Chrome/Chromium browser plug-in.
#
# device-trust   - Installs the Device Trust Component.
#                  See https://www.citrix.com/platform/devicetrust.html.
#
# gnome          - Installs the Multitouch Plug-In for the GNOME desktop.
#                  The use flag is currently masked, because it is not
#                  implemented and I have no way to test it.
#                  This use flags serves as a reminder that this feature
#                  exist.
#                  See `install_oskext()` of the upstream setup script for
#                  references if you want to add this feature.
#
# gstreamer      - Enables remote sound playback via GStreamer
#
# microsoft-edge - Installs the Edge browser plug-in.
#
# systemd        - Installs the SystemD service files and enables them.
#                  This use flag is currently enforced, because the
#                  alternative (sysv-utils) is not implemented.
#
# sysv-utils     - Installs the SysV-style init scripts and enables them.
#                  This use flag is currently maskedm because it is not
#                  implemented and I have no way to test it.
#                  This use flags serves as a reminder that this feature
#                  exist.
#                  Analyze the upstream setup script VERY carefully if
#                  you want to add this feature.
#                  The upstream setup script is a mess regarding the
#                  creation of init scripts as they setup script does
#                  not have a consistent way how it does so, but uses
#                  a weird mix of HEREDOCs inside the script, sed scripts
#                  and prepared files to create init scripts.
#                  The functions are all scattered across the scipt.
#
# usb            - Enables USB support
#
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
	acct-user/citrixlog
"

pkg_nofetch() {
	einfo "Please download"
	einfo "    linuxx64-${PV}.tar.gz"
	einfo "from"
	einfo "    ${HOMEPAGE}"
	einfo "and place them in your DISTDIR as"
	einfo "    ${P}.tar.gz"
}
