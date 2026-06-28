# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="KDE SDK - merge this to pull in all kdesdk-derived packages"
HOMEPAGE="https://apps.kde.org/categories/development/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 arm64 ~x86"
IUSE="+git mercurial subversion"

RDEPEND="
	>=dev-build/dolphin-plugins-makefileactions-${PV}:*
	>=kde-apps/kdesdk-thumbnailers-${PV}:*
	>=kde-apps/kompare-${PV}:*
	>=kde-apps/libkomparediff2-${PV}:*
	git? ( >=kde-apps/dolphin-plugins-git-${PV}:* )
	mercurial? ( >=kde-apps/dolphin-plugins-mercurial-${PV}:* )
	subversion? ( >=kde-apps/dolphin-plugins-subversion-${PV}:* )
"
