EAPI=8

# See [CMAKE.ECLASS](https://devmanual.gentoo.org/eclass-reference/cmake.eclass/index.html)
inherit cmake ffmpeg-compat

DESCRIPTION="CasparCG Server plays out professional graphics, audio and video to multiple outputs. It has been in 24/7 broadcast production since 2006."
HOMEPAGE="https://casparcg.com/"

# Upon download, rename unspecific `vX.Y.Z.-stable.tar.gz` to a file whose name contains the
# full package name plus version,
# See [Ebuild Writing - SRC_URI](https://devmanual.gentoo.org/ebuild-writing/variables/index.html#src_uri)
SRC_URI="https://github.com/CasparCG/server/archive/refs/tags/v${PV}-stable.tar.gz -> ${P}.tar.gz"

# The tar-archive contains a subdirectory with the sources "server-x.y.z-stable" whose name differs from
# the package name.
# Overwrite the source directory `$S` with the correct directory.
# The default is `${WORKDIR}/${P}`, see [Ebuild Writing - Ebuild-defined Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html#ebuild-defined-variables)
S="${WORKDIR}/server-${PV}-stable/src"

# Always download the source from upstream, do not try to download it from a
# Gentoo mirror.
# See [Ebuild Writing - Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html)
# and `man 5 ebuild`.
RESTRICT="mirror"

# See `/var/db/repos/gentoo/licenses` for a list of known licenses.
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="amd64"

# dev-cpp/tbb                  from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (TBB REQUIRED)
# >=dev-libs/boost-1.67.0:*    from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (Booost 1.67.0)
# dev-libs/icu                 from src/shell/CMakeLists.txt: target_link_libraries(casparcg ... icui18n icuuc ...)
# dev-libs/nss                 from tools/linux/install-dependencies and output of `ldd` on final executable
# media-libs/freeimage         from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (FreeImage)
# media-libs/glew              from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (GLEW)
# media-libs/libglvnd          from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (OpenGL)
# >=media-libs/libsfml-2.0.0   from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (SFML 2)
# media-libs/openal            from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (OpenAL)
# media-video/ffmpeg           from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (FFmpeg)
# sys-libs/zlib                from src/shell/CMakeLists.txt: target_link_libraries(casparcg ... z ...)
# x11-libs/libICE              from linker output
# x11-libs/libSM               from linker output
# x11-libs/libX11              from src/CMakeModules/Bootstrap_Linux.cmake: FIND_PACKAGE (X11)
# x11-libs/libXext             from linker output
RDEPEND="dev-cpp/tbb
	>=dev-libs/boost-1.67.0:*
	dev-libs/icu
	dev-libs/nss
	media-libs/freeimage
	media-libs/glew
	media-libs/libglvnd
	>=media-libs/libsfml-2.0.0
	media-libs/openal
	media-video/ffmpeg-compat:6=
	sys-libs/zlib
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}"
BDEPEND="dev-util/patchelf"

# See https://devmanual.gentoo.org/quickstart/index.html#ebuild-with-patches
PATCHES=(
	"${FILESDIR}/${P}-add-missing-includes.patch"
	"${FILESDIR}/${P}-fix-boost-1.85.patch"
	"${FILESDIR}/${P}-fix-linker-dependencies.patch"
)

# For variable $DOCS, see [Ebuild Writing - Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html)
# For `einstalldocs`, see [Install functions reference](https://devmanual.gentoo.org/function-reference/install-functions/index.html)
# We must go up one directory level, because $DOCS is relative to $S and we set $S to the ./src subdirectory above.
DOCS=(
	"../CHANGELOG.md"
	"../README.md"
)

#
# The eclass cmake uses `MYCMAKEARGS` and passes them to CMake, see
# [CMAKE.ECLASS](https://devmanual.gentoo.org/eclass-reference/cmake.eclass/index.html).
#
#  1. Option `USE_STATIC_BOOST=OFF`:
#     Gentoo only installs the shared libraries for Boost.
#     Upstream documentation [BUILDING.md](https://github.com/CasparCG/server/blob/master/BUILDING.md) claims that `OFF` was the
#     default for Linux, but `CMakeLists.txt` from the sources defines it the other way around.
#     We disable static libs explicitly.
#  2. Option `USE_SYSTEM_FFMPEG=ON`:
#     The upstream build script attempts to download addiotional sources for FFMpeg itself,
#     which isn't allowed due to sandboxing.
#     The option `USE_SYSTEM_FFMPEG` is not documented upstream, but it is in `CMakeLists.txt`.
#  3. Option `ENABLE_HTML=OFF`:
#     Enabling this option requires the CEF library which must either be provided as a system library or
#     is downloaded by the build script.
#     However, we haven't figured out what this CEF library is, hence we deactivate HTML for now.
#  4. Option `USE_SYSTEM_CEF=ON`
#     The upstream build script attempts to download addiotional sources for CEF itself,
#     which isn't allowed due to sandboxing.
#     The option `USE_SYSTEM_CEF` is not documented upstream, but it is in `CMakeLists.txt`.
#
MYCMAKEARGS=" -DUSE_STATIC_BOOST=OFF -DUSE_SYSTEM_FFMPEG=ON -DENABLE_HTML=OFF -DUSE_SYSTEM_CEF=ON"

# Caspar CG <2.5 depends on FFmpeg 6
# Hence, this ebuild
#  - inherits eclass `ffmpeg-compat`
#  - depends on `media-video/ffmpeg-compat:6=`
#  - and calls `ffmpeg_compat_setup 6` before the source code gets configured, see
#    [FFMPEG-COMPAT.ECLASS](https://devmanual.gentoo.org/eclass-reference/ffmpeg-compat.eclass/index.html)
#
# Caspar CG >= 2.5 and future versions support FFmpeg 7, see https://github.com/CasparCG/server/issues/1629.
# TODO: Remove this in ebuilds for versions >= 2.5.
src_configure() {
	ffmpeg_compat_setup 6
#	ffmpeg_compat_add_flags
	cmake_src_configure
}


#
# The CMake script of Caspar CG does not define an `install` target.
# Hence, we must enroll our own install script.
# This function essentially executes three blocks:
#  1. _Preliminary steps:_
#     Execute the same commands as the default implementation
#     `cmake_src_install` would do, before the missing `cmake install` would
#     be called
#  2. _Install files:_
#     Execute the actual installation commands as a substitute for the
#     missing `cmake install`
#  3. _Final steps:_
#     Execute the same commands as the default implementation
#     `cmake_src_install` would do, after the missing `cmake install` would
#     have been called
#
src_install() {
	# Preliminary default step from the eclass, see `cmake_src_install`
	debug-print-function ${FUNCNAME} "$@"

	# The function `cmake_src_install` from the eclass `cmake` would run
	# ```
	# DESTDIR="${D}" cmake_build install "$@"
	# ```
	# but this doesn't work as the build script does not provide the
	# usual target `install`.
	# Hence, we must take the necessary steps manually.

	# The Ninja build script creates the directory
	# ```
	# ${BUILD_DIR}/staging
	# ```
	# which contains all files which need to be installed.
	#
	# The main binary is `${BUILD_DIR}/staging/bin/casparcg`.
	# (Note: The Eclass `cmake` sets the variable `${BUILD_DIR}` which points
	# to the directory for the out-of-tree build, see [CMAKE.ECLASS](https://devmanual.gentoo.org/eclass-reference/cmake.eclass/index.html)).
	#
	# The original Docker build runs the follwing code
	# ```
	# mkdir ${BUILD_DIR}/staging/lib || die
	# ${S}/shell/copy_deps.sh ${BUILD_DIR}/staging/bin/casparcg ${BUILD_DIR}/staging/lib
	# ```
	#
	# The project-provided script `copy_deps.sh` uses `ldd` to collect _all_
	# shared libraries for `casparcg` and and copies them to staging/lib.
	# This also includes system-provided libraries like stdc++, boost, etc.,
	# which we must not install again.
	# So here we only collect the couple of project-specific libraries
	# from the build directory manually and install them.
	
	pushd "${BUILD_DIR}" > /dev/null || die
	
	local CASPARCG_LIBS="
		accelerator/libaccelerator.so
		common/libcommon.so
		core/libcore.so
		modules/artnet/libartnet.so
		modules/decklink/libdecklink.so
		modules/ffmpeg/libffmpeg.so
		modules/image/libimage.so
		modules/newtek/libnewtek.so
		modules/oal/liboal.so
		modules/screen/libscreen.so
		protocol/libprotocol.so
	"
	
	local FFMPEG6_PREFIX_PATH=$(ffmpeg_compat_get_prefix 6)
	
	for CASPARCG_LIB in ${CASPARCG_LIBS}; do
		dolib.so "${CASPARCG_LIB}"
		patchelf --set-rpath ${FFMPEG6_PREFIX_PATH%/}/lib64:/usr/lib64 "${ED%/}/usr/lib64/"$(basename "${CASPARCG_LIB}")
	done
	
	dobin staging/bin/casparcg
	patchelf --set-rpath ${FFMPEG6_PREFIX_PATH%/}/lib64:/usr/lib64 ${ED%/}/usr/bin/casparcg
	dodoc staging/casparcg.config
	docompress -x /usr/share/doc/${PF}/casparcg.config
	popd > /dev/null || die
	
	insinto /usr/lib/systemd/user
	doins "${FILESDIR}/casparcg-server.service"

	# Final default steps from the eclass, see `cmake_src_install`
	pushd "${CMAKE_USE_DIR}" > /dev/null || die
	einstalldocs
	popd > /dev/null || die
}
