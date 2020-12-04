# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="netCDF4"
MY_P="${MY_PN}-${PV}"

PYTHON_COMPAT=( python3_{6,7,8} )
inherit distutils-r1

DESCRIPTION="Python interface to the netCDF C library."
HOMEPAGE="https://unidata.github.io/netcdf4-python"
RESTRICT="mirror"
SRC_URI="mirror://pypi/${P:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dap hdf mpi"

RDEPEND="dev-python/cftime[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.9[${PYTHON_USEDEP}]
	>=sci-libs/hdf5-1.8.4
	>=sci-libs/netcdf-4.6.1[hdf5]
	dap? ( >=net-misc/curl-7.64.0
			>=sci-libs/netcdf-4.6.1[dap] )
	hdf? ( >=sci-libs/hdf-4.2.8
		>=sci-libs/netcdf-4.6.1[hdf] )
	mpi? ( >=dev-python/mpi4py-2.0.0
			>=sci-libs/netcdf-4.6.1[mpi] )"

S="${WORKDIR}"/${MY_P}
DEPEND="${RDEPEND}
	>=dev-python/setuptools-18.0[${PYTHON_USEDEP}]
	>=dev-python/cython-0.19[${PYTHON_USEDEP}]"
