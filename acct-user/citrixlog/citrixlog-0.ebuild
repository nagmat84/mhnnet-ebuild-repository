# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="Citrix Workspace Logger user"
SLOT=0

ACCT_USER_ID=749
ACCT_USER_GROUPS=( nobody )
ACCT_USER_HOME=/var/log/citrix
ACCT_USER_HOME_PERMS=0700
acct-user_add_deps
