# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="kdeutils - merge this to pull in all kdeutils-derived packages"
HOMEPAGE="https://apps.kde.org/categories/utilities/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 arm64 ~x86"
IUSE="7zip gpg lrz markdown plasma rar"

RDEPEND="
	>=app-cdr/dolphin-plugins-mountiso-${PV}:*
	>=app-cdr/isoimagewriter-${PV}:*
	>=app-crypt/keysmith-${PV}
	>=dev-libs/kweathercore-${PV}:*
	>=kde-apps/ark-${PV}:*
	>=kde-apps/filelight-${PV}:*
	>=kde-apps/kate-${PV}:*
	>=kde-apps/kcalc-${PV}:*
	>=kde-apps/kcharselect-${PV}:*
	>=kde-apps/kdebugsettings-${PV}:*
	>=kde-apps/kdf-${PV}:*
	>=kde-apps/kwalletmanager-${PV}:*
	>=kde-misc/kweather-${PV}:*
	>=kde-misc/markdownpart-${PV}:*
	>=sys-block/partitionmanager-${PV}:*
	>=sys-libs/kpmcore-${PV}:*
	gpg? ( >=kde-apps/kgpg-${PV}:* )
	plasma? ( >=kde-misc/kclock-${PV} )
	markdown? ( >=app-editors/ghostwriter-${PV} )
"
# Optional runtime deps: kde-apps/ark
RDEPEND="${RDEPEND}
	7zip? ( app-arch/p7zip )
	lrz? ( app-arch/lrzip )
	rar? ( || (
		app-arch/rar
		app-arch/unrar
		app-arch/unar
	) )
"
