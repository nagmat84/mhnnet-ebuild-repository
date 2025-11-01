EAPI=8

DESCRIPTION="A small assembly of helper scripts to manage Gentoo installations"
HOMEPAGE="https://github.com/nagmat84/${PN}/"

# Upon download, rename unspecific "vX.Y.Z.tar.gz" such that the file name contains the
# full package name plus version,
# see [Ebuild Writing - SRC_URI](https://devmanual.gentoo.org/ebuild-writing/variables/index.html#src_uri)
SRC_URI="https://github.com/nagmat84/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# Always download the source from upstream, do not try to download it from a
# Gentoo mirror.
# See [Ebuild Writing - Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html)
# and `man 5 ebuild`.
RESTRICT="mirror"

# See "/var/db/repos/gentoo/licenses" for a list of known licenses.
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="amd64"

RDEPEND="
 net-misc/rsync
 virtual/ssh
"
