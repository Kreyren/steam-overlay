# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-multilib versionator

# This ebuild is based on the one from gamerlay. It multibuilds and
# adds a symlink required for the steam client.

MY_PN="SDL"
REV="$(get_version_component_range 4)"
MY_P="${MY_PN}-$(get_version_component_range 1-3)-${REV/pre/}"

DESCRIPTION="Simple Direct Media Layer"
HOMEPAGE="http://www.libsdl.org/"
SRC_URI="http://www.libsdl.org/tmp/${MY_P}.tar.gz"

LICENSE="ZLIB"
SLOT="2"
KEYWORDS=""
IUSE="3dnow alsa altivec +asm aqua fusionsound gles mmx nas opengl oss pulseaudio sse sse2 static-libs +threads tslib +video X +xcursor +xinput xinerama xscreensaver xrandr xvidmode"

#FIXME: Replace "gles" deps with "virtual/opengles", after hitting Portage.
RDEPEND="
	nas? (
		media-libs/nas[${MULTILIB_USEDEP}]
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
		x11-libs/libXt[${MULTILIB_USEDEP}]
	)
	X? (
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXcursor[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
		x11-libs/libXi[${MULTILIB_USEDEP}]
		x11-libs/libXt[${MULTILIB_USEDEP}]
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
		x11-libs/libXrender[${MULTILIB_USEDEP}]
		x11-libs/libXxf86vm[${MULTILIB_USEDEP}]
	)
	xinerama? ( x11-libs/libXinerama[${MULTILIB_USEDEP}] )
	xscreensaver? ( x11-libs/libXScrnSaver[${MULTILIB_USEDEP}] )
	alsa? ( media-libs/alsa-lib )
	fusionsound? ( >=media-libs/FusionSound-1.1.1 )
	pulseaudio? ( >=media-sound/pulseaudio-0.9 )
	gles? ( || ( media-libs/mesa[gles2] media-libs/mesa[gles] ) )
	opengl? ( virtual/opengl )
	tslib? ( x11-libs/tslib[${MULTILIB_USEDEP}] )
"

DEPEND="${RDEPEND}
	nas? (
		x11-proto/xextproto[${MULTILIB_USEDEP}]
		x11-proto/xproto[${MULTILIB_USEDEP}]
	)
	X? (
		x11-proto/inputproto[${MULTILIB_USEDEP}]
		x11-proto/xextproto[${MULTILIB_USEDEP}]
		x11-proto/xf86vidmodeproto[${MULTILIB_USEDEP}]
		x11-proto/xproto[${MULTILIB_USEDEP}]
		x11-proto/randrproto[${MULTILIB_USEDEP}]
		x11-proto/renderproto[${MULTILIB_USEDEP}]
	)
	xinerama? ( x11-proto/xineramaproto[${MULTILIB_USEDEP}] )
	xscreensaver? ( x11-proto/scrnsaverproto[${MULTILIB_USEDEP}] )
"

S=${WORKDIR}/${MY_P}

src_prepare() {
	einfo "Patching header to make them arch-independent"
	sed -i "s/#cmakedefine SIZEOF_VOIDP @SIZEOF_VOIDP@.*/#define SIZEOF_VOIDP sizeof(void*)/" ${S}/include/SDL_config.h.cmake || die asd

	# fix from Azamat H. Hackimov from Gamerlay
	epatch "${FILESDIR}"/fix-libX11_1_5_99-compatibility.patch
	epatch "${FILESDIR}"/libsdl-universal_xdata32_check.patch
}

src_configure() {
	mycmakeargs=(
		# Disable assertion tests.
		-DASSERTIONS=disabled
		# Avoid hard-coding RPATH entries into dynamically linked SDL libraries.
		-DRPATH=NO
		# Disable obsolete and/or inapplicable libraries.
		-DARTS=NO
		-DESD=NO
		$(cmake-utils_use 3dnow 3DNOW)
		$(cmake-utils_use alsa ALSA)
		$(cmake-utils_use altivec ALTIVEC)
		$(cmake-utils_use asm ASSEMBLY)
		$(cmake-utils_use aqua VIDEO_COCOA)
		$(cmake-utils_use fusionsound FUSIONSOUND)
		$(cmake-utils_use gles VIDEO_OPENGLES)
		$(cmake-utils_use mmx MMX)
		$(cmake-utils_use nas NAS)
		$(cmake-utils_use opengl VIDEO_OPENGL)
		$(cmake-utils_use oss OSS)
		$(cmake-utils_use pulseaudio PULSEAUDIO)
		$(cmake-utils_use threads PTHREADS)
		$(cmake-utils_use sse SSE)
		$(cmake-utils_use sse SSEMATH)
		$(cmake-utils_use sse2 SSE2)
		$(cmake-utils_use static-libs SDL_STATIC)
		$(cmake-utils_use tslib INPUT_TSLIB)
		$(cmake-utils_use video VIDEO_DUMMY)
		$(cmake-utils_use X VIDEO_X11)
		$(cmake-utils_use xcursor VIDEO_X11_XCURSOR)
		$(cmake-utils_use xinerama VIDEO_X11_XINERAMA)
		$(cmake-utils_use xinput VIDEO_X11_XINPUT)
		$(cmake-utils_use xrandr VIDEO_X11_XRANDR)
		$(cmake-utils_use xscreensaver VIDEO_X11_XSCRNSAVER)
		$(cmake-utils_use xvidmode VIDEO_X11_XVM)
		#$(cmake-utils_use joystick SDL_JOYSTICK)
	)
	cmake-multilib_src_configure
}

create_symlink_for_steam() {
	cd ${D}/usr/$(get_libdir)
	ln -s libSDL2.so.2.0.0 libSDL2-2.0.so.0
}

src_install() {
	cmake-multilib_src_install

	dodoc BUGS.txt CREDITS.txt TODO.txt WhatsNew.txt README*

	# create symlink for Valve's steam client
	multilib_foreach_abi create_symlink_for_steam
}
