EAPI=8

DESCRIPTION="Pulls in required build tools for a build server"
HOMEPAGE="https://www.mhnnet.de/"
LICENSE="metapackage"

SLOT="0"
KEYWORDS="amd64"

#
# app-misc/resolve-march-native  is required to find common ISA extensions between CPUs
# app-portage/cpuid2cpuflags     dito
# app-portage/getuto             manages keys to sign/verify binary packages
# dev-util/debugedit             is required by Portage features "compressdebug" and "splitdebug"
#
RDEPEND="
 app-misc/resolve-march-native
 app-portage/cpuid2cpuflags
 app-portage/getuto
 dev-util/debugedit
"
