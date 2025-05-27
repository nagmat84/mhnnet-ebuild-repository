EAPI=8

DESCRIPTION="Intel IPU6 camera binaries (Meteor/Raptor Lake)"
HOMEPAGE="https://github.com/intel/ipu6-camera-bins"
SRC_URI="https://github.com/intel/ipu6-camera-bins/archive/refs/tags/v${PV}-iot-mtl-rpl-v6.12.tar.gz -> ${P}.tar.gz"
LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror"

BDEPEND="dev-util/patchelf"
DEPEND="sys-libs/glibc"
RDEPEND="
	${DEPEND}
	!sys-firmware/ipu6-camera-bins-arl-twl-asl
"

S="${WORKDIR}/ipu6-camera-bins-${PV}-iot-mtl-rpl-v6.12"

src_install() {
	dolib.so "${S}/lib/"*.so.0
	dolib.a "${S}/lib/"*.a 
	doheader -r "${S}/include"/*
	
	insinto /usr/lib64/pkgconfig
	doins "${S}/lib/pkgconfig"/*.pc
	
	# Fixing paths
	for sofile in "${D}/usr/lib64"/*.so*; do
		patchelf --set-rpath /usr/lib64 "${sofile}"
	done
}
