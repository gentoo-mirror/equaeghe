# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
inherit distutils-r1

DESCRIPTION="Time-handling functionality from netcdf4-python"
HOMEPAGE="https://github.com/Unidata/cftime"
RESTRICT="mirror"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# more dependencies should be added to deal with docs and tests
# see https://github.com/Unidata/cftime/blob/master/requirements-dev.txt

RDEPEND=">=dev-python/numpy-1.8.2[${PYTHON_USEDEP}]"
# It is actually unclear what is the required minimal numpy version

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]"
