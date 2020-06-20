# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
MY_PV=$(ver_rs 2 -)
MY_P="${PN}-v${MY_PV}"

inherit savedconfig

DESCRIPTION="An open source firmware and bootloader for POWER, ARM, MIPS, x86 and others"
HOMEPAGE="https://www.denx.de/wiki/U-Boot"
SRC_URI="https://gitlab.denx.de/${PN}/${PN}/-/archive/v${MY_PV}/${PN}-v${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~arm64"
IUSE="build-tfa"

DEPEND="
	sys-apps/dtc
	!build-tfa? ( sys-firmware/trusted-firmware-a-bin:= )
	build-tfa? ( sys-firmware/trusted-firmware-a:= )"
RDEPEND="${DEPEND}"
BDEPEND=""
S="${WORKDIR}/${MY_P}"
TFADIR="/usr/share/trusted-firmware-a"

src_configure() {
	if use savedconfig; then
		restore_config .config
	else
		emake ${U_BOOT_CONFIG} || die
	fi
}

src_compile() {
	#Safe bet for now
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS

	#Uboot seems very gcc-centric, clang support will be... adventurous
	export CROSS_COMPILE="${CHOST}-"

	if use savedconfig; then
		emake BL31="${BL31PATH}" || die
		einfo "built u-boot with savedconfig"
	else
		case ${U_BOOT_CONFIG} in
			qemu_arm64_defconfig)
				emake || die
				;;
			rock64-rk3328_defconfig)
				emake BL31=${TFADIR}/rk3328/bl31.elf || die
				;;
			rockpro64-rk3399_defconfig|pinebook-pro-rk3399_defconfig)
				emake BL31=${TFADIR}/rk3399/bl31.elf || die
				;;
			pine64-lts_defconfig|pine64_plus_defconfig|pinebook_defconfig|pine_h64_defconfig)
				emake BL31=${TFADIR}/sun50i_a64/bl31.elf || die
				;;
			rpi_4_defconfig)
				emake BL31=${TFADIR}/rpi4/bl31.elf || die
				;;
			**)
				eerror "unsupported platform"
				eerror "please submit a bug if you want your platform supported"
				;;
		esac
		einfo "built u-boot with ${U_BOOT_CONFIG} configuration"
	fi

}

src_install() {
	insinto /usr/share/u-boot

	case ${U_BOOT_CONFIG} in
		qemu_arm64_defconfig)
			# Only u-boot.bin *should* be necessary, others helpful for debug?
			# Perhaps debug useflag if other targets also build symbols, maps etc.
			doins u-boot
			doins u-boot.bin
			doins u-boot.lds
			doins u-boot.map
			doins u-boot-nodtb.bin
			doins u-boot.srec
			doins u-boot.sym
			;;
		rock64-rk3328_defconfig)
			;;
		rockpro64-rk3399_defconfig|pinebook-pro-rk3399_defconfig)
			doins idbloader.img
			doins u-boot.itb
			;;
		pine64-lts_defconfig|pine64_plus_defconfig|pinebook_defconfig|pine_h64_defconfig)
			cat spl/sunxi-spl.bin u-boot.itb > u-boot-sunxi-with-spl-pine64.bin
			doins u-boot-sunxi-with-spl-pine64.bin
			;;
		rpi_4_defconfig)
			cp u-boot.bin kernel8.img
			doins kernel8.img
			;;
	esac
}

pkg_postinst() {
	if ! use savedconfig; then
		elog "To install U-Boot:"

		case ${U_BOOT_CONFIG} in
			qemu_arm64_defconfig)
				# Documentation on this on the wiki would be helpful, TBD
				elog "point qemu bios at u-boot.bin : qemu-system-aarch64 -bios /usr/share/u-boot/u-boot.bin"
				;;
			rock64-rk3328_defconfig)
				;;
			rockpro64-rk3399_defconfig|pinebook-pro-rk3399_defconfig)
				elog "dd if=/usr/share/u-boot/idbloader.img of=/dev/... seek=64 conv=notrunc"
				elog "dd if=/usr/share/u-boot/u-boot.itb of=/dev/... seek=16384 conv=notrunc"
				elog "where /dev/... can either be the SD or eMMC"
				;;
			pine64-lts_defconfig|pine64_plus_defconfig|pinebook_defconfig|pine_h64_defconfig)
				;;
			rpi_4_defconfig)
				;;
		esac
	fi
}
