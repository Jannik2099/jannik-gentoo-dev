# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Trusted Firmware for A profile Arm CPUs"
HOMEPAGE="https://www.trustedfirmware.org/"
SRC_URI="https://git.trustedfirmware.org/TF-A/${PN}.git/snapshot/${P}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~arm64"

PLATFORMS="rk3399 rk3328 sun50i_a64 rpi4"
for platform in ${PLATFORMS}; do
	IUSE_ARM_PLATFORM+="arm_platform_${platform} "
done

IUSE="${IUSE_ARM_PLATFORM}"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_compile() {
	#Safe bet for now
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS

	for platform in ${PLATFORMS}; do
		if use arm_platform_${platform}; then
			emake CROSS_COMPILE=aarch64-unknown-linux-gnu- PLAT=${platform} || die
		fi
	done
}

src_install() {
	INSTDIR="${D}/usr/share/${PN}"
	mkdir -p "${INSTDIR}"

	for platform in ${PLATFORMS}; do
		if use arm_platform_${platform}; then
			mkdir "${INSTDIR}/${platform}" && find "${S}/build/${platform}" | grep -E '(bl31\.bin|bl31\.elf)' | xargs -I {} cp {} "${INSTDIR}/${platform}" || die
		fi
	done
}
