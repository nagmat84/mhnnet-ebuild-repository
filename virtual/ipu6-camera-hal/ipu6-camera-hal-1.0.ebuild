EAPI=8

DESCRIPTION="Intel IPU6 camera HAL"
HOMEPAGE="https://github.com/intel/ipu6-camera-hal"
LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"

IUSE="alderlake arrowlake meteorlake raptorlake"

REQUIRED_USE="^^ ( alderlake arrowlake meteorlake raptorlake )"

RDEPEND="
	alderlake? ( sys-libs/ipu6-camera-hal-arl-twl-asl )
	arrowlake? ( sys-libs/ipu6-camera-hal-arl-twl-asl )
	meteorlake? ( sys-libs/ipu6-camera-hal-mtl-rpl[meteorlake] )
	raptorlake? ( sys-libs/ipu6-camera-hal-mtl-rpl[raptorlake] )
"
