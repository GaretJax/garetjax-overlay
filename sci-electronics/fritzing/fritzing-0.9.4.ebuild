# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# CI_BUILD_ID="${PV}"
CI_BUILD_ID="CD-353"
S="${WORKDIR}/${PN}-app-${CI_BUILD_ID}"
PARTS_P="${PN}-parts-0.9.3b"

inherit qmake-utils

DESCRIPTION="Electronic Design Automation"
HOMEPAGE="http://fritzing.org/"
SRC_URI="https://github.com/fritzing/fritzing-app/archive/${CI_BUILD_ID}.tar.gz -> fritzing-app-${CI_BUILD_ID}.tar.gz
	https://github.com/fritzing/fritzing-parts/archive/0.9.3b.tar.gz -> ${PARTS_P}.tar.gz"

LICENSE="CC-BY-SA-3.0 GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtserialport:5
	dev-qt/qtsql:5[sqlite]
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	>=dev-libs/quazip-0.7.2[qt5(+)]"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.40"

DOCS="README.md"

src_prepare() {
	# fix build with newer quazip - bug #597988
	sed -i -e "s/#include <quazip/&5/" src/utils/folderutils.cpp || die
	sed -i -e "s|/usr/include/quazip|&5|" -e "s/-lquazip/&5/" phoenix.pro || die

	# Get a rid of the bundled libs
	# Bug 412555 and
	# https://code.google.com/p/fritzing/issues/detail?id=1898
	rm -rf src/lib/quazip/ pri/quazip.pri || die

	# Fritzing doesn't need zlib
	sed -i -e 's:LIBS += -lz::' phoenix.pro || die

	default
}

src_configure() {
	eqmake5 DEFINES=QUAZIP_INSTALLED phoenix.pro
}

src_install() {
	INSTALL_ROOT="${D}" default

	insinto /usr/share/fritzing/parts
	doins -r "${WORKDIR}/${PARTS_P}"/*
}
