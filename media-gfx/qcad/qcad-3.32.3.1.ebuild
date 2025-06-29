EAPI=8

inherit cmake desktop qmake-utils wrapper xdg

DESCRIPTION="Open Source 2D CAD"
HOMEPAGE="http://www.qcad.org/"
SRC_URI="https://github.com/${PN}/qtjsapi/archive/refs/tags/v${PV}.tar.gz -> qtjsapi-${PV}.tar.gz
https://github.com/${PN}/qcadjsapi/archive/refs/tags/v${PV}.tar.gz -> qcadjsapi-${PV}.tar.gz
https://github.com/${PN}/qcad/archive/refs/tags/v${PV}.tar.gz -> qcad-${PV}.tar.gz"

# Always download the source from upstream, do not try to download it from a
# Gentoo mirror.
# See [Ebuild Writing - Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html)
# and `man 5 ebuild`.
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

L10N=( ar bg ca cs da de el en es et fa fi fr gd gl he hr hu id it ja ko lt lv nb nl nn pl pt pt_BR pt_PT ro ru sk sl sv th tr uk zh_CN zh_TW )

IUSE=""

for lingua in ${L10N[*]}; do
	IUSE+=" l10n_${lingua}"
done

DEPEND="
	media-libs/libglvnd
	dev-qt/qtbase:6=
	dev-qt/qt5compat:6=
	dev-qt/qtdeclarative:6=
	dev-qt/qtsvg:6=
	dev-qt/qttools:6=
	dev-qt/qtbase:6=
	sys-libs/glibc
	sys-devel/gcc
"
RDEPEND="${DEPEND}"

#
# QCad for QT6 consists of three upstream projects which are deeply interlinked with each other.
# The projects QtJsAPI and QCadJsApi even create files inside QCad during built time.
#
# The CMake files assume that all projects reside in the named respective directories (without version numbers) within the same parent directory.
# Without heavy patching of the CMake files this cannot be changed.
#
# However, Portage assumes a) that there is only a single source/project diretory and b) the directory name
# contains a version specifier.
#
# We overwrite the various Emerge phases and use the following variable to iterate over the project directories.
#
QCAD_PROJECTS="qcad qtjsapi qcadjsapi"

#
# Per default, $S points to the root source directory "${WORKDIR}/${P}".
# As we have to deal with three projects (see above), there is no single
# source directory and hence no good default choice for $S.
# We have to iterate over $QCAD_PROJECTS anyways for each ebuild phase.
# Hence, we set ${S} to ${WORKDIR} to catch any accidental mistake.
#
S="${WORKDIR}"

#
# QCad various CMake files assume an in-tree built, also see previous comment.
#
CMAKE_IN_SOURCE_BUILD="1"

QCAD_CMAKE_ARGS="-DBUILD_QT6=ON"
QCAD_PATCHES=( "${FILESDIR}"/${PN}-freetype-fpic.patch )

#
# Calls default implementation to unpack all archives and renames the
# directories such that they do not include a version number
#
src_unpack() {
	default_src_unpack
	for QCAD_PROJECT in ${QCAD_PROJECTS}; do
		ln -s ${QCAD_PROJECT}-${PV} ${QCAD_PROJECT} || die
	done
}

#
# Iterates over three QCad projects and calls the default implementation.
# src_prepare assumes that
#  - $S points to the source directory and
#  - the working directory is $S
# cmake.eclass internally uses the variables
#  - CMAKE_USE_DIR (for the source directory) and
#  - BUILD_DIR (for the build directory)
# cmake.eclass sets those variables only once at the beginning to $S.
# However, as we have to deal with three projects.
# Hence, we set $S, $PWD, $CMAKE_USE_DIR and $BUILD_DIR in each iteration
# and change the directory accordingly before we call the default
# implementation.
#
src_prepare() {
	# Remove deselected language files from QCad main project
	pushd "${WORKDIR}/${PN}"
	for lingua in "${L10N[@]}"
	do
		if ! use l10n_${lingua}
		then
			find -type f -name "*_${lingua}.qm" -or -name "*_${lingua}.ts" -or -name "*_${lingua}.html" -delete
			# drop translation but leave the line continuation mark at the end of each line
			sed -i "s|\$\$.*/\$\${NAME}_${lingua}\.ts||" shared_ts.pri scripts/Misc/translations.pri || die
			sed -i "s|.*ts/.*_${lingua}\.qm.*||" src/scripts/*.qrc
		fi
	done
	popd

	# Call cmake.eclass default for each project, see comment at function start
	for QCAD_PROJECT in ${QCAD_PROJECTS}; do
		S="${WORKDIR}/${QCAD_PROJECT}"
		pushd $S
		PWD=$S
		CMAKE_USE_DIR=$S
		BUILD_DIR=$S
		if [[ "${QCAD_PROJECT}" == "qcad" ]]; then
			PATCHES=("${QCAD_PATCHES[@]}")
		else
			PATCHES=()
		fi
		cmake_src_prepare
		popd
	done
}

#
# See comment for src_prepare
#
src_configure() {
	for QCAD_PROJECT in ${QCAD_PROJECTS}; do
		S="${WORKDIR}/${QCAD_PROJECT}"
		pushd $S
		PWD=$S
		CMAKE_USE_DIR=$S
		BUILD_DIR=$S
		# The eclass cmake uses `MYCMAKEARGS` and passes them to CMake, see
		# [CMAKE.ECLASS](https://devmanual.gentoo.org/eclass-reference/cmake.eclass/index.html).
		if [[ "${QCAD_PROJECT}" == "qcad" ]]; then
			MYCMAKEARGS="${QCAD_CMAKE_ARGS}"
		else
			MYCMAKEARGS=
		fi
		cmake_src_configure
		popd
	done
}

#
# See comment for src_prepare
#
src_compile() {
	for QCAD_PROJECT in ${QCAD_PROJECTS}; do
		S="${WORKDIR}/${QCAD_PROJECT}"
		pushd $S
		PWD=$S
		CMAKE_USE_DIR=$S
		BUILD_DIR=$S
		cmake_src_compile
		popd
	done
}

#
# See comment for src_prepare
#
src_test() {
	for QCAD_PROJECT in ${QCAD_PROJECTS}; do
		S="${WORKDIR}/${QCAD_PROJECT}"
		pushd $S
		PWD=$S
		CMAKE_USE_DIR=$S
		BUILD_DIR=$S
		cmake_src_test
		popd
	done
}

#
# QCad does not provide a proper "install" target.
# We must install manually.
# The auxiliary projects QtJsApi and QCadJsApi create their build files
# in the QCad directory as plug-ins.
# Hence, this function only needs to deal with the QCad project.
#
src_install() {
	S="${WORKDIR}/${PN}"
	pushd $S
	PWD=$S

	# Remove build and project files which do not need to be installed
	find . -type f -name '.gitignore' -or -name '*.pro' -or -name '*.pri' -or -name 'readme.txt' -delete || die

	# The final installation directory for QCad which is going to host
	# the actual binary (qcad-bin) plus all QCad-specific libraries, scripts
	# and plugins.
	# qt-utils.eclass provides qt6_get_libdir.
	local qcad_dir=$(qt6_get_libdir)/${PN}

	# Needs desktop.eclass
	domenu ${PN}.desktop
	doicon scripts/${PN}_icon.svg
	doicon --size 256 scripts/${PN}_icon.png

	insinto ${qcad_dir}/
	doins -r fonts libraries linetypes patterns themes ts

	# scripts get compiled into plugins/libqcadscripts.so (which is faster)
	# we also install them as documentation and to allow modification if desired
	keepdir ${qcad_dir}/scripts
	docinto scripts
	dodoc -r scripts/*
	docompress -x /usr/share/doc/${PF}/scripts

	# If the CMake build type is "Release", the QCad build system creates
	# the executable and libraries in "release/*", otherweise in "debug/*".
	# As Gentoo also uses the build type "RelWithDebInfo" we must always
	# install the content of potentially both directories.
	insopts -m0755
	[[ -d release ]] && doins release/*
	[[ -d debug ]] && doins debug/*
	doins -r plugins platform* xcb*
	# For some reason QCad does not build/move these two libraries into release/debug
	doins src/3rdparty/dxflib/libdxflib.so src/3rdparty/stemmer/libstemmer.so

	# The actual QCad executable (qcad-bin) requires QCad-specified
	# libraries and scans the "${qcad_dir}/plugin" directory to find the
	# QCad-proprietary TypeScript interpreter which is built by QCadJsApi.
	# Here we create a wrapper script "qcad" which invokes qcad-bin and
	# sets the LD_PATH accordingly.
	# wrapper.eclass provides make_wrapper.
	# make_wrapper <wrapper name> <target> [chdir] [libpath] [install dir for wrapper=/usr/bin/]
	make_wrapper ${PN} ${qcad_dir}/qcad-bin "" ${qcad_dir}:${qcad_dir}/plugins || die

	docinto examples
	dodoc -r examples/*
	docompress -x /usr/share/doc/${PF}/examples

	doman ${PN}.1

	popd
}
