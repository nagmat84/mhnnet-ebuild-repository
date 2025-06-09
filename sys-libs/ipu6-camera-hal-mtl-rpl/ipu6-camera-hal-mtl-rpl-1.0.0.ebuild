EAPI=8

inherit cmake

DESCRIPTION="Intel IPU6 camera HAL (Meteor/Raptor Lake)"
HOMEPAGE="https://github.com/intel/ipu6-camera-hal"
SRC_URI="https://github.com/intel/ipu6-camera-hal/archive/refs/tags/v${PV}-iot-mtl-rpl-v6.12.tar.gz -> ${P}.tar.gz"
LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"

IUSE="meteorlake raptorlake"
REQUIRED_USE="^^ ( meteorlake raptorlake )"

RESTRICT="mirror"

BDEPEND="dev-build/cmake
	dev-build/ninja"
DEPEND="sys-firmware/ipu6-camera-bins-mtl-rpl"
RDEPEND="
	${DEPEND}
	!sys-libs/ipu6-camera-hal-arl-twl-asl
"

S="${WORKDIR}/ipu6-camera-hal-${PV}-iot-mtl-rpl-v6.12"

MYCMAKEARGS=" -DBUILD_CAMHAL_ADAPTOR=ON -DBUILD_CAMHAL_PLUGIN=ON -DUSE_PG_LITE_PIPE=ON "

src_configure() {
	if use meteorlake ; then
		MYCMAKEARGS="${MYCMAKEARGS} -DIPU_VERSIONS=ipu6epmtl"
	fi
	cmake_src_configure
}
