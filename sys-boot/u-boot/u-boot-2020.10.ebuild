# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
MY_PV=$(ver_rs 2 -)
MY_P="${PN}-v${MY_PV}"

inherit savedconfig

DESCRIPTION="An open source firmware and bootloader for POWER, ARM, MIPS, x86 and others"
HOMEPAGE="https://www.denx.de/wiki/U-Boot"
SRC_URI="https://gitlab.denx.de/${PN}/${PN}/-/archive/v${MY_PV}/${PN}-v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~arm64"
IUSE="build-tfa"

RDEPEND="
	sys-apps/dtc
	!build-tfa? ( sys-firmware/trusted-firmware-a-bin )
	build-tfa? ( sys-firmware/trusted-firmware-a )"
S="${WORKDIR}/${MY_P}"

src_prepare() {
	default
	restore_config .config
}

src_compile() {
	# ebuild.sh complains on a empty src_compile() {}, is there a "cleaner" way?
	echo
}

src_install() {
	test -f .config && save_config .config
	insinto /usr/src
	doins -r "${S}"
}

pkg_postinst() {
	savedconfig_pkg_postinst
	einfo "For instructions on how to use u-boot, please check the wiki page:"
	# here be my wiki page
}
