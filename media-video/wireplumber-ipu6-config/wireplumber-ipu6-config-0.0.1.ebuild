EAPI=8

DESCRIPTION="A config file for IPU6 and Wire Plumber"
HOMEPAGE="https://github.com/nagmat84/mhnnet-ebuild-repository"

LICENSE="GPL-3"

SLOT="0"
KEYWORDS="amd64"

S="${FILESDIR}"

src_install() {
	insinto /etc/wireplumber/wireplumber.conf.d/
	doins lenovo-disable-v4l2-and-prefer-libcamera.conf
}
