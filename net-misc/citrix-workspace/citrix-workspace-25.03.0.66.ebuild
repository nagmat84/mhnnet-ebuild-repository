EAPI=8

inherit desktop systemd udev user-info xdg
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

SRC_PKG_CORE="/linuxx64-${PV}/linuxx64/linuxx64.cor"
SRC_PKG_USB="${SRC_PKG_CORE}/usb"

ICA_INSTALL_PATH="/opt/Citrix/ICAClient"

##
## Helper functions which mimic the behavior of the upsream setup script.
##

#
# Installs the Citrix USB Support (ctxusb).
# Intended ebuild phases:
#  - `src_install` (depending on use flag "usb")
# Covered functions of upstream setup script:
#  - `installCtxusb()`
#  - `integrateDeamon()`
#  - `patch_module_ini()`
#
install_ctx_usb() {
	# See `installCtxusb()` of upstream setup script
	insinto ${ICA_INSTALL_PATH}
	exeinto ${ICA_INSTALL_PATH}
	exeopts -m 755
	doexe "${SRC_PKG_USB}/VDGUSB.DLL"
	doexe "${SRC_PKG_USB}/cty_usb_isactive"

	exeopts -m 4755
	doexe "${SRC_PKG_USB}/ctxusb"

	exeopts -m 700
	doexe "${SRC_PKG_USB}/ctxusbd"

	insopts -m 644
	doins "${SRC_PKG_USB}/usb.conf"

	udev_dorules "${FILESDIR}/usb-support/85-ica-usb.rules"

	# See `patch_moduleini()` of upstream setup script
	local CONFIG_FILE="${ED%/}${ICA_INSTALL_PATH}/config/module.ini"
	[[ -e ${CONFIGFILE} ]] || die "File ${CONFIG_FILE} is missing"
	sed \
		-e 's/^[ \t]*VirtualDriver[ \t]*=.*$/&, GenericUSB/' \
		-e '/\[ICA 3.0\]/a\GenericUSB=on' \
		<"${CONFIG_FILE}" \
		>"${CONFIG_FILE}.tmp" || die "Could not patch ${CONFIG_FILE}"
	echo "[GenericUSB]" >> "${CONFIG_FILE}.tmp"
	echo "DriverName = VDGUSB.DLL" >> "${CONFIG_FILE}.tmp"
	mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

	# See `integrateDaemon()` of upstream setup script
	use "systemd" && systemd_dounit "${FILESDIR}/usb-support/ctxusbd.service"
}

#
# Iterates over all user directories and clear caches.
# 
# Intended ebuild phases:
#  - `pkg_postinst()`
#  - `pkg_postrm()`
# Covered functions of upstream setup script:
#  - `delete_service_worker_cache()`
#  - `delete_customdimensionssent_from_ICAHome()`
#  - `check_InvalidConnectionLease()`
#  - `delete_InvalidConnectionLease()`
#  - `delete_leaselaunch_cache()`
#  - `delete_shieldkid()`
#
clear_user_caches() {
	local USER_HOMES=$(egetent passwd | awk -F: '$3 >= 1000 && $3 <= 60000 {print $6}')
	for USER_HOME in ${USER_HOMES}; do
		[[ -z "${USER_HOME}" ]] && continue
		pushd "${USER_HOME}"

		# See `delete_service_worker_cache()` of upstream setup script
		[[ -d .cache/selfservice ]] && rm -rf .cache/selfservice
		if [[ -d .local/share ]] ; then
			pushd .local/share
			[[ -d webkitgtk/localstorage   ]]   && rm -rf webkitgtk/localstorage/*
			[[ -d webkitgtk/serviceworkers ]]   && rm -rf webkitgtk/serviceworkers/*
			[[ -d selfservice/localstorage ]]   && rm -rf selfservice/localstorage/*
			[[ -d selfservice/serviceworkers ]] && rm -rf selfservice/serviceworkers/*
			popd # .local/share
		fi

		pushd .ICAClient
		# See `delete_customdimensionssent_from_ICAHome()` of upstream setup script
		[[ -f .customdimensions_sent ]]  && rm -f .customdimensions_sent
		# See `delete_InvalidConnectionLease()` of upstream setup script
		find cache/ConnectionLease -type d -name "leases" -exec rm -rf '{}' ';'
		# See `delete_leaselaunch_cache()` of upstream setup script
		find cache/Stores -type f -name '*$LeaseLaunch_Cache_*' -delete
		# See `delete_shieldkid()` of upstream setup script
		[[ -f ShieldKid ]] && rm -f ShieldKid
		popd  #.ICAClient
		
		popd # ${USER_HOME}
	done
}

##
## Ebuild phases
##

pkg_nofetch() {
	einfo "Please download"
	einfo "    linuxx64-${PV}.tar.gz"
	einfo "from"
	einfo "    ${HOMEPAGE}"
	einfo "and place them in your DISTDIR as"
	einfo "    ${P}.tar.gz"
}

src_unpack() {
	unpack ${P}.tar.gz

	if use "app-protection"; then
		# See `install_AppProtectionFiles()` of upstream setup script
		true
	fi

	if use "device-trust"; then
		# See `unzip_deviceTrustZip()` of upstream setup script
		true
	fi
}

src_install() {
	return
	
	# Install core package
	
	# See `create_wfica_script()` called by `netscape_integrate()` of upstream setup script
	exeinto "${ICA_INSTALL_PATH}"
	exeopts -m 755
	doexe "${FILESDIR}/core/wfica.sh"
	
	# See `DT_integrate()` and `DT_register_MIMEs()`of upstream setup script
	# We install the *.desktop, *.xml mime and icon files; they are picked up
	# by eclass `xdg` during `pkg_preinst`, `pkg_postinst` and `pkg_postrm`
	domenu ${FILESDIR}/core/*.desktop
	insopts -m 644
	insinto /usr/share/mime/application
	doins ${FILESDIR}/core/mime/vnd.citrix.{receiver.configure,x-ica}.xml
	insinto /usr/share/mime/x-scheme-handler
	doins ${FILESDIR}/core/mime/vnd.citrix.{authwebviewdone,linuxamloauth,receiver}.xml
	newicon -s 256 ${ED%/}/${ICA_INSTALL_PATH}/icons/utility.png   citrix-utility.png
	newicon -s 256 ${ED%/}/${ICA_INSTALL_PATH}/icons/receiver.png  citrix-receiver.png
	
	use "usb" && install_ctx_usb
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	clear_user_caches
	
	if use "usb" ; then
		# See `removeDaemon()` of upstream setup script
		use "systemd"  && systemd_reenable ctxusbd.service
	fi
	xdg_pkg_postinst
	udev_reload
}

pkg_postrm() {
	clear_user_caches
	xdg_pkg_postrm
	udev_reload
}
