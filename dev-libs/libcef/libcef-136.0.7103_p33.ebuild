EAPI=8

# See [GIT-R3.ECLASS](https://devmanual.gentoo.org/eclass-reference/git-r3.eclass/index.html)
# See [CMAKE.ECLASS](https://devmanual.gentoo.org/eclass-reference/cmake.eclass/index.html)
inherit git-r3 cmake

DESCRIPTION="Chromium Embedded Framework (CEF). A simple framework for embedding Chromium-based browsers in other applications."
HOMEPAGE="https://github.com/chromiumembedded/cef/"

# Upon download, rename unspecific `vX.Y.Z.-stable.tar.gz` to a file whose name contains the
# full package name plus version,
# See [Ebuild Writing - SRC_URI](https://devmanual.gentoo.org/ebuild-writing/variables/index.html#src_uri)
#SRC_URI="https://github.com/CasparCG/server/archive/refs/tags/v${PV}-stable.tar.gz -> ${P}.tar.gz"

EGIT_REPO_URI="https://github.com/chromiumembedded/cef.git"
EGIT_BRANCH=$(ver_cut 3 ${PV})
EGIT_COMMIT="4dec9aa"

# The tar-archive contains a subdirectory with the sources "server-x.y.z-stable" whose name differs from
# the package name.
# Overwrite the source directory `$S` with the correct directory.
# The default is `${WORKDIR}/${P}`, see [Ebuild Writing - Ebuild-defined Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html#ebuild-defined-variables)
#S="${WORKDIR}/server-${PV}-stable/src"

# Always download the source from upstream, do not try to download it from a
# Gentoo mirror.
# See [Ebuild Writing - Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html)
# and `man 5 ebuild`.
RESTRICT="mirror"

# See `/var/db/repos/gentoo/licenses` for a list of known licenses.
# TODO: Fix the license, CEF has its own one.
#LICENSE="google-chrome"

SLOT="0"
KEYWORDS="amd64"

RDEPEND=""
DEPEND="${RDEPEND}"

# See https://devmanual.gentoo.org/quickstart/index.html#ebuild-with-patches
PATCHES=(
)

DOCS=(
	"AUTHORS.txt"
	"CHROMIUM_BUILD_COMPATIBILITY.txt"
	"CHROMIUM_UPDATE.txt"
	"README.md"
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
#MYCMAKEARGS=" -DUSE_STATIC_BOOST=OFF -DUSE_SYSTEM_FFMPEG=ON -DENABLE_HTML=OFF -DUSE_SYSTEM_CEF=ON"


# From [EBUILD]:
#
# > Should contain everything required to install the package in the temporary install directory.
# > If src_install is undefined then the following default implementation is used: [...]
# > Initial working directory: $S
#
# From [Sandbox]:
#
# > Portage installs an image of the package in question from ${S} into ${D}.
# > Ebuilds must not attempt to perform any operation upon the live filesystem at this stage.
# > This will break binaries, and will (often) cause a sandbox violation notice.
#src_install() {
#}
