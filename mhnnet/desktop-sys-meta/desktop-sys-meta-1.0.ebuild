EAPI=8

DESCRIPTION="Pulls in required system utilities and deamons for desktop environments"
HOMEPAGE="https://www.mhnnet.de/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="geoclue geolocation modemmanager zeroconf"

#
# sys-auth/nss-mdns  is required by app-misc/geoclue if zeroconf is enabled
# sys-auth/rtkit     is required by media/pipewire
#
RDEPEND="
 geoclue? ( zeroconf? ( sys-auth/nss-mdns ) )
 geolocation? ( zeroconf? ( sys-auth/nss-mdns ) )
 sys-auth/rtkit
"

pkg_postinst() {
	elog "Pipewire requires RTKit to be running."
	elog "Enable RTKit via 'systemctl enable rtkit-daemon.service'."

	if ( use geoclue || use geolocation ) && use zeroconf; then
		elog "Geoclue requires Avahi to be running."
		elog "Enable Avahi via 'systemctl enable avahi-daemon.service'."
		elog "Ensure that systemd-resolved does not interfere with Avahi."
		elog "Place a suitable configuration file in /etc/systemd/resolved.conf.d/ to"
		elog "disable  multicast DNS for systemd-resolved."
		elog "Also configure /etc/nsswitch.conf as requested by sys-auth/nss-mdns."

		elog "Geoclue requires MomdemManager to be running."
		elog "Enable MomdemManager via 'systemctl enable ModemManager.service'."
	fi
}
