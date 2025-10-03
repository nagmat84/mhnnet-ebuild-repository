EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} )

# See https://projects.gentoo.org/python/guide/eclass.html
inherit distutils-r1 pypi

DESCRIPTION="deSEC DNS Authenticator plugin for Certbot"
HOMEPAGE="
        https://pypi.org/project/certbot-dns-desec/
        https://github.com/desec-io/certbot-dns-desec
"

# Always download the source from upstream, do not try to download it from a
# Gentoo mirror.
# See [Ebuild Writing - Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html)
# and `man 5 ebuild`.
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
        dev-python/dnspython[${PYTHON_USEDEP}]
        dev-python/requests[${PYTHON_USEDEP}]
"
BDEPEND="test? (
        dev-python/mock[${PYTHON_USEDEP}]
        dev-python/requests-mock[${PYTHON_USEDEP}]
)"

distutils_enable_tests pytest
