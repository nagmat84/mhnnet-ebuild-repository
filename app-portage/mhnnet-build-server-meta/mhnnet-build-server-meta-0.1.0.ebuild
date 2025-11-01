EAPI=8

DESCRIPTION="Pulls in required build tools for a build server"
HOMEPAGE="https://www.mhnnet.de/"
LICENSE="metapackage"

SLOT="0"
KEYWORDS="amd64"

#
# dev-util/debugedit  is required by Portage features "compressdebug" and "splitdebug"
#
RDEPEND="
 app-portage/getuto
 dev-util/debugedit
"
