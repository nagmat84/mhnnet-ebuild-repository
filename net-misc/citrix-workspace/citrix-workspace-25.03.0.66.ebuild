EAPI=8

inherit desktop systemd udev xdg
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

S_CORE="${WORKDIR}/${P}-core"
S_USB="${WORKDIR}/${P}-usb"
S_APP_PROTECTION="${WORKDIR}/${P}-app-protection"
S_DEVICE_TRUST="${WORKDIR}/${P}-device-trust"

S="${S_CORE}"

ICA_INSTALL_PATH="/opt/Citrix/ICAClient"

# List of SystemD unit files which are installed by the various `install_...`
# methods and needs to be enabled in the post installation phase.
SYSTEMD_SERVICES_TO_BE_ENABLED=( )

##
## Helper functions which mimic the behavior of the upsream setup script.
##

#
# Installs the script wfica.sh.
#
# This functions mimics `create_wfica_script()` of the upstream setup script
# which is part of `netscape_integrate()` and installs the script `wfica.sh`
# even if no NS plugins are installed.
# Note that the NS-style plug-ins are completely outdated and Mozilla Firefox
# dropped support for the NS-style plug-ins long time ago.
# Chance are that the shell script serves no purpose at all.
# We install it anyway.
#
# Intended ebuild phases:
#  - `src_install`
# Covered functions of upstream setup script:
#  - `create_wfica_script()`
#  - `create_wfica_script()`
#
install_wfica_script() {
	# See `create_wfica_script()` called by `create_wfica_script()` of
	# upstream setup script
	exeinto "${ICA_INSTALL_PATH}"
	exeopts -m 755
	doexe "${FILESDIR}/core/wfica.sh"
}


#
# Installs the *.desktop, MIME XML and icon files.
#
# The files installed here do not exist as proper files inside the upstream
# TAR archive, but the upstream setup script creates those files on-the-fly
# from a wild mix of HEREDOC, sed and egrep commands.
# Moreover, in doing so it also produces invalid files.
# We extracted the files content from the upstream setup script and fixed
# some errors.
#
#  - The desktop files are used as provided, only icon references are
#    changed to `citrix-utility` and `citrix-receiver`.
#  - The MIME files
#     - `vnd.citrix.receiver.configure.xml`
#     - `vnd.citrix.x-ica.xml`
#    are the result of a split of the upstream file `Citrix-mime_types.xml`
#  - The MIME files
#     - `vnd.citrix.authwebviewdone.xml`
#     - `vnd.citrix.linuxamloauth.xml`
#     - `vnd.citrix.receiver.xml`
#    are created from the HEREDOC for `/etc/xdg/mimeapps.list`
#  - The icons are prefixed with `citrix-...` to avoid a name clash and the
#    files above are changed accordingly.
#
# Intended ebuild phases:
#  - `src_install`
# Covered functions of upstream setup script:
#  - `DT_integrate()`
#  - `DT_register_MIMEs()`
#
install_desktop_files() {
	# We install the *.desktop, *.xml mime and icon files; they are picked up
	# by eclass `xdg` during `pkg_preinst`, `pkg_postinst` and `pkg_postrm`
	domenu ${FILESDIR}/core/*.desktop
	insopts -m 644
	insinto /usr/share/mime/application
	doins ${FILESDIR}/core/mime/vnd.citrix.{receiver.configure,x-ica}.xml
	insinto /usr/share/mime/x-scheme-handler
	doins ${FILESDIR}/core/mime/vnd.citrix.{authwebviewdone,linuxamloauth,receiver}.xml
	newicon -s  16 ${ED%/}${ICA_INSTALL_PATH}/icons/000_Receiver_16.png  citrix-receiver.png
	newicon -s  64 ${ED%/}${ICA_INSTALL_PATH}/icons/000_Receiver_64.png  citrix-receiver.png
	newicon -s 256 ${ED%/}${ICA_INSTALL_PATH}/icons/receiver.png         citrix-receiver.png
	newicon -s 256 ${ED%/}${ICA_INSTALL_PATH}/icons/utility.png          citrix-utility.png
}


#
# Installs the GStreamer support
#
# Intended ebuild phases:
#  - `src_install` (depending on use flag `gstreamer`)
# Covered functions of upstream setup script:
#  - `GST_integrate()`
#  - `GST_get_target_dirs()`
#
install_gstreamer_support() {
	# TODO: Check if its fine to _not_ install gst_{play,read}0.1,
	# _directly_ install gst_{play,read}1.0 as gst_{play,read}, and
	# not use symlinks at all
	dosym -r \
		${ICA_INSTALL_PATH}/util/gst_play1.0 \
		${ICA_INSTALL_PATH}/util/gst_play
	dosym -r \
		${ICA_INSTALL_PATH}/util/gst_read1.0 \
		${ICA_INSTALL_PATH}/util/gst_read
	
	# Install GStreamer plugins
	# TODO: Check if installing the files into GStreamer is better
	dosym -r \
		${ICA_INSTALL_PATH}/util/libgstflatstm1.0.so \
		/usr/lib64/gstreamer-1.0/libgstflatstm.so
	dosym -r \
		${ICA_INSTALL_PATH}/lib/libctxbeffect.so \
		/usr/lib64/gstreamer-1.0/libctxbeffect.so
	
	# NOTE: This is what GST_integrate() of the upstream setup script does
	# even though it looks strange.
	# The option "-n" only creates the symbolic links, but does not update
	# the loader cache.
	ldconfig -n ${ED%/}${ICA_INSTALL_PATH}/lib/third_party
}


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
	# The idea to resolve the symbolic link and patch the real file
	# is inspired by the setup script of the Device Trust component
	local CONFIG_FILE="${ED%/}${ICA_INSTALL_PATH}/config/module.ini"
	[[ -L ${CONFIG_FILE} ]] && CONFIG_FILE=$(realpath "${CONFIG_FILE}")
	[[ -f ${CONFIG_FILE} ]] || die "File ${CONFIG_FILE} is missing"
	local CONFIG_FILE_TMP="${T}/$(basename ${CONFIG_FILE}).tmp"
	sed \
		-e 's/^[ \t]*VirtualDriver[ \t]*=.*$/&, GenericUSB/' \
		-e '/\[ICA 3.0\]/a\GenericUSB=on' \
		<"${CONFIG_FILE}" \
		>"${CONFIG_FILE_TMP}" \
		|| die "Could not enable USB Support Package in ${CONFIG_FILE}"
	echo "[GenericUSB]" >> "${CONFIG_FILE_TMP}"
	echo "DriverName = VDGUSB.DLL" >> "${CONFIG_FILE_TMP}"
	mv "${CONFIG_FILE_TMP}" "${CONFIG_FILE}"

	# See `integrateDaemon()` of upstream setup script
	if use "systemd"; then
		systemd_dounit "${FILESDIR}/usb-support/ctxusbd.service"
		SYSTEMD_SERVICES_TO_BE_ENABLED+=( "ctxusbd.service" )
	fi
}


#
# Installs the Citrix App Protection Component.
#
# BUG: This method function is incomplete.
# It does not properly consider the upgrade case from a previous version.
# This function does not contain a migrated variant of the method
# `upgrade_AppProtection` of the upstream setup script and does not handle
# the mandatory system reboot between uninstalling the previous and
# installing the new version.
# BUG: Citrix AppProtection prevents certain "forbidden" user actions through
# pre-loading a shared object file (AppProtection.so) at a very early boot
# stage which intercepts standard library calls which Citrix considers
# "harmful" and either mocks, modifies or relays those library calls.
# Some quick tests revealed that this component does not work well with
# Gentoo.
# For example, it let xwaylandbride utilize 100% of a single CPU core.
# Also App Protection prevents modification to itself on a filesystem
# level, i.e. after App Protection has been installed once, the only way
# to remove or replace it with a newer version is to reboot the system
# and not pre-load AppProtection.so on the next boot cycle.
# I have no idea how to properly do implement such a package upgrade
# with ebuilds.
#
# Intended ebuild phases:
#  - `src_install` (depending on use flag "app-protection")
# Covered functions of upstream setup script:
#  - `install_AppProtection()`
#  - `install_AppProtectionFiles()`
# NOT covered functions of upstream setup script:
#  - `upgrade_AppProtection()` (see above)
#
install_app_protection() {
	eerror "Installing the App Protection Component"
	eerror ""
	eerror "YOU SHOULD NOT DO THIS."
	eerror ""
	eerror "This component deeply encroaches on other libraries, including necessary"
	eerror "system libraries. Chances are that this component heavily impairs your system"
	eerror "and even renders it unbootable. After this component has successfully been"
	eerror "installed _and_ works, it might not be easy to remove this component from"
	eerror "within the booted system again as this is intended by design. However, due to"
	eerror "its fragile nature it might also happen, that this component has no effect at"
	eerror "all."
	die
	
	# NOTE: For clarification
	# The "install" services/scripts/... _inject_ the AppProtection.so very
	# early in the boot phase.
	# The "remove" services/scripts/... _evict_ the AppProtection.so before
	# during the shutdown sequence as otherwise the system would be unable to
	# halt and eventually power down.
	#
	# Better names than install/remove are inject/evict or simply load/unload.
	# However, we do _not_ rename the service files and scripts as we would
	# need to patch too many other files.
	#
	# To make matters worse: There is also another "preload-library-remove.sh"
	# script which actually uninstalls AppProtection.so, but this is not that
	# script below.
	#
	# What a mess.
	pushd "${S_APP_PROTECTION}/usr/lib/systemd/system/"
	exeinto /usr/lib/systemd/system
	exeopts -m755
	newexe preload-library-remove.sh
	local APP_PROTECTION_SERVICE_FILES=(\
		"AppProtectionService.service" \
		"preload-library-install.service" \
		"preload-library-remove.service" \
	)
	systemd_dounit "${APP_PROTECTION_SERVICE_FILES[@]}"
	SYSTEMD_SERVICES_TO_BE_ENABLED+=("${APP_PROTECTION_SERVICE_FILES[@]}")
	popd
	
	if use "gnome"; then
		pushd "${S_APP_PROTECTION}/usr/share/gnome-shell"
		insinto /usr/share/gnome-shell
		doins -r extensions/
		popd
	fi
	
	pushd "${S_APP_PROTECTION}/usr/local/bin/AppProtection/"
	exeinto /usr/bin
	exeopts -m755
	doexe *
	popd
	
	pushd "${S_APP_PROTECTION}/usr/local/lib/AppProtection/"
	exeinto /usr/lib
	newexe libAppProtection.so.Release libAppProtection.so
	popd
}


#
# Installs the Browser Extension for Chromium-based browsers (Chrome,
# Chromium, Edge).
#
# This method works closely together with `activate_browser_extension`.
# This method installs the necessary system-wide files, while
# `activate_browser_extension` creates the necessary files in the
# user directories during the post-installation phase.
#
# Intended ebuild phases:
#  - `src_install` (depending on use flag "chrome" or "microsoft-edge")
# Covered functions of upstream setup script:
#  - `install_browser_extension()`
#  - `install_extension()`
#  - `create_ceb_native_messaging_host_file`
#  - `create_apparmor_profile_if_required`
#
install_browser_extension() {
	insinto /etc/chromium/native-messaging-hosts
	insopts -m0644
	doins "${FILESDIR}/browser/com.citrix.chrome.ipcbridge.json"
	
	if use "apparmor"; then
		die "AppArmor support is not yet implemented"
		# TODO: Extract the app armor cofiguration from the HEREDOC inside
		# the upstream setup script create_apparmor_profile_if_required(),
		# put the file in ${FILESDIR} and install it into the correct
		# system-wide app armor configuration directory for Gentoo.
	fi
}


#
# Installs the Device Trust component.
#
# Intended ebuild phases:
#  - `src_install` (depending on use flag "device-trust")
# Covered functions of upstream setup script:
#  - `install_deviceTrust()`
#  - `run_deviceTrustScripts()`
install_device_trust() {
	S_DEVICE_TRUST
	
	pushd "${S_DEVICE_TRUST}"
	
	systemd_dounit dtclient.service dtclient.socket
	SYSTEMD_SERVICES_TO_BE_ENABLED+=( "dtclient.socket" )
	dobin dtclientd
	dolib.so libdtclient_*.so
	
	local CONFIG_FILE="${ED%/}${ICA_INSTALL_PATH}/config/module.ini"
	[[ -L ${CONFIG_FILE} ]] && CONFIG_FILE=$(realpath "${CONFIG_FILE}")
	[[ -f ${CONFIG_FILE} ]] || die "File ${CONFIG_FILE} is missing"
	local CONFIG_FILE_TMP="${T}/$(basename ${CONFIG_FILE}).tmp"
	awk \
		-v register=1 -f "${S_DEVICE_TRUST}/deploy.awk" \
		"${CONFIG_FILE}" \
		> "${CONFIG_FILE_TMP}" \
		|| die "Could not enable Device Trust Component in ${CONFIG_FILE}"
	mv "${CONFIG_FILE_TMP}" "${CONFIG_FILE}"
	
	popd
}

#
# Clear caches within current user directory.
#
# This method assumes that the current working directory is the user directory.
# 
# Parameters: <user name> <user group> <user home>
#
# Intended ebuild phases:
#  - `pkg_postinst()`
#  - `pkg_prerm()`
# Covered functions of upstream setup script:
#  - `delete_service_worker_cache()`
#  - `delete_customdimensionssent_from_ICAHome()`
#  - `check_InvalidConnectionLease()`
#  - `delete_InvalidConnectionLease()`
#  - `delete_leaselaunch_cache()`
#  - `delete_shieldkid()`
#
clear_user_caches() {
	[[ "$(pwd)" == "$3" ]] || die "Internal ebuild error: Unexpected current working directory"
	
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
}


#
# Activates the browser extension for the selected user.
#
# This method assumes that the current working directory is the user directory.
# This method works closely together with `install_browser_extension`.
# This method creates the necessary files in the user directories, while
# `install_browser_extension` installs the necessary system-wide files  during
# the installation phase.
# 
# Parameters: <user name> <user group> <user home>
#
# Intended ebuild phases:
#  - `pkg_postinst()`
# Covered functions of upstream setup script:
#  - `create_manifest_file()`
#
activate_browser_extension() {
	[[ "$(pwd)" == "$3" ]] || die "Internal ebuild error: Unexpected current working directory"
	local USER="$1"
	local GROUP="$2"
	local DIE_MSG="Could not active browser extension for $3"
	local BROWSER_DIRS=()
	use "chrome"         && BROWSER_DIRS+=( "google-chrome" )
	use "microsoft-edge" && BROWSER_DIRS+=( "microsoft-edge-beta" )
	
	for BROWSER_DIR in "${BROWSER_DIRS[@]}"; do
		install \
			-o ${USER} -g ${GROUP} -m 0750 \
			-d .config/${BROWSER_DIR}/NativeMessagingHosts \
			|| die "${DIE_MSG}"
		install \
			-o ${USER} -g ${GROUP} -m 0640 \
			"${FILESDIR}/browser/com.citrix.workspace.native.json" \
			.config/${BROWSER_DIR}/NativeMessagingHosts/ \
			|| die "${DIE_MSG}"
	done
}


#
# Deactivates the browser extension for the selected user.
#
# This method assumes that the current working directory is the user directory.
# 
# Parameters: <user name> <user group> <user home>
#
# Intended ebuild phases:
#  - `pkg_prerm()`
# Covered functions of upstream setup script:
#  - `uninstall_browser_extension()`
#  - `uninstall_extension()`
#
deactive_browser_extension() {
	[[ "$(pwd)" == "$3" ]] || die "Internal ebuild error: Unexpected current working directory"
	local BROWSER_DIRS=( "google-chrome" "microsoft-edge-beta" )
	for BROWSER_DIR in "${BROWSER_DIRS[@]}"; do
		rm -rf .config/${BROWSER_DIR}/NativeMessagingHosts/com.citrix.workspace.native.json
	done
}


#
# Iterates over all user directories and performs post-installation steps.
#
# This method invokes performs the steps:
#  - activate_browser_extension
#  - clear_user_caches
# 
# Intended ebuild phases:
#  - `pkg_postinst()`
adjust_user_homes_postinst() {
	local USER_DB=( $(getent passwd | awk -F: '$3 >= 1000 && $3 <= 60000 {print $1":"$6}') )
	for USER_ENTRY in "${USER_DB[@]}"; do
		local USER_NAME=${USER_ENTRY%:*}
		local USER_HOME=${USER_ENTRY#*:}
		local USER_GROUP=$(id -gn ${USER_NAME})
		[[ -z "${USER_HOME}" ]] && continue
		pushd "${USER_HOME}"
		if use "chrome" || use "microsoft-edge"; then
			activate_browser_extension "${USER_NAME}" "${USER_GROUP}" "${USER_HOME}"
		fi
		clear_user_caches "${USER_NAME}" "${USER_GROUP}" "${USER_HOME}"
		popd # ${USER_HOME}
	done
	
	pushd /etc/skel
	if use "chrome" || use "microsoft-edge"; then
		activate_browser_extension root root /etc/skel
	fi
	popd # /etc/skel
}


#
# Iterates over all user directories and performs pre-removal steps.
#
# This method invokes performs the steps:
#  - deactivate_browser_extension
#  - clear_user_caches
# 
# Intended ebuild phases:
#  - `pkg_prerm()`
adjust_user_homes_prerm() {
	local USER_DB=( $(getent passwd | awk -F: '$3 >= 1000 && $3 <= 60000 {print $1":"$6}') )
	for USER_ENTRY in "${USER_DB[@]}"; do
		local USER_NAME=${USER_ENTRY%:*}
		local USER_HOME=${USER_ENTRY#*:}
		local USER_GROUP=$(id -gn ${USER_NAME})
		[[ -z "${USER_HOME}" ]] && continue
		pushd "${USER_HOME}"
		deactivate_browser_extension "${USER_NAME}" "${USER_GROUP}" "${USER_HOME}"
		clear_user_caches "${USER_NAME}" "${USER_GROUP}" "${USER_HOME}"
		popd # ${USER_HOME}
	done
	
	pushd /etc/skel
	deactive_browser_extension root root /etc/skel
	popd # /etc/skel
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
	# Core Package
	unpack ${P}.tar.gz
	mv "${WORKDIR}/linuxx64-${PV}/linuxx64/linuxx64.cor" "${S_CORE}"
	rm -rf "${WORKDIR}/linuxx64-${PV}"

	# USB package
	# NOTE: The USB package is not an individual archive, but simply a directory
	# within the core package
	mv "${S_CORE}/usb" "${S_USB}"

	# App Protection package
	unpack "${S_CORE}/util/AppProtection-service.tar.gz"
	mv "${WORKDIR}/AppProtection-service/AppProtectionService-install" "${S_APP_PROTECTION}"
	rm -rf "${WORKDIR}/AppProtection-service/"
	rm -rf "${S_CORE}/util/AppProtection-service.tar.gz"
	
	# Device Trust package
	unpack "${S_CORE}/DeviceTrust/dtclient-linux-amd64-release.zip"
	rm -rf "${S_CORE}/DeviceTrust"
	unpack "${WORKDIR}/dtclient-linux-amd64-release/dtclient.tar.gz"
	rm "${WORKDIR}/dtclient-linux-amd64-release"
	mv "dtclient" "${S_DEVICE_TRUST}"
	
	# Delete irrelevant files
	rm "${S_CORE}/DeepFilterNet3_onnx.tar.gz"
}

src_install() {
	return
	
	# TODO: Install core package
	
	install_wfica_script
	
	install_desktop_files
	
	use "gstreamer" && install_gstreamer_support
	
	use "app-protection" && install_app_protection
	
	if use "chrome" || use "microsoft-edge"; then
		install_browser_extension
	fi
	
	use "device-trust" && install_device_trust
	
	use "usb" && install_ctx_usb
	
	# TODO: gnome extension
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	adjust_user_homes_postinst
	use "systemd" && systemd_reenable "${SYSTEMD_SERVICES_TO_BE_ENABLED[@]}"
	xdg_pkg_postinst
	udev_reload
}

pkg_prerm() {
	adjust_user_homes_prerm
}

pkg_postrm() {
	xdg_pkg_postrm
	udev_reload
}
