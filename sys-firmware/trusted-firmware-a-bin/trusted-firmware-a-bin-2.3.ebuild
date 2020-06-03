# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Trusted Firmware for A profile Arm CPUs - precompiled binaries"
HOMEPAGE="https://www.trustedfirmware.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~arm64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	!sys-firmware/trusted-firmware-a"
BDEPEND=""

src_unpack() {
	mkdir "${S}"
	cp -r "${FILESDIR}/trusted-firmware-a" "${S}"
}

src_install() {
	insinto /usr/share
	cp -r "${S}/trusted-firmware-a" "${D}"
}
