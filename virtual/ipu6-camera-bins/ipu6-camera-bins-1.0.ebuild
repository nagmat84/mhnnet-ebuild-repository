EAPI=8

DESCRIPTION="Intel IPU6 camera binaries"
HOMEPAGE="https://github.com/intel/ipu6-camera-bins"
LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"

IUSE="alderlake arrowlake meteorlake raptorlake"

REQUIRED_USE="^^ ( alderlake arrowlake meteorlake raptorlake )"

RDEPEND="
	alderlake? ( sys-firmware/ipu6-camera-bins-arl-twl-asl )
	arrowlake? ( sys-firmware/ipu6-camera-bins-arl-twl-asl )
	meteorlake? ( sys-firmware/ipu6-camera-bins-mtl-rpl )
	raptorlake? ( sys-firmware/ipu6-camera-bins-mtl-rpl )
"
