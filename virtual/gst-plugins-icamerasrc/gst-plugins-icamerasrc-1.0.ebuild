EAPI=8

DESCRIPTION="Intel IPU6 camera HAL"
HOMEPAGE="https://github.com/intel/icamerasrc"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"

IUSE="alderlake arrowlake meteorlake raptorlake"

REQUIRED_USE="^^ ( alderlake arrowlake meteorlake raptorlake )"

RDEPEND="
	alderlake? ( media-plugins/gst-plugins-icamerasrc-arl-twl-asl )
	arrowlake? ( media-plugins/gst-plugins-icamerasrc-arl-twl-asl )
	meteorlake? ( media-plugins/gst-plugins-icamerasrc-mtl-rpl )
	raptorlake? ( media-plugins/gst-plugins-icamerasrc-mtl-rpl )
"
