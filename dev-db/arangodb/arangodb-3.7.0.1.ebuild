# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..8} )
CMAKE_MAKEFILE_GENERATOR="emake" # because of https://github.com/ninja-build/ninja/issues/1139
CHECKREQS_DISK_BUILD="12G"

inherit eutils user systemd python-any-r1 cmake-utils check-reqs toolchain-funcs

DESCRIPTION="Multi-model highly available NoSQL database"
HOMEPAGE="http://www.arangodb.org/"

GITHUB_USER="arangodb"
GITHUB_TAG="v${PV}"

SRC_URI="https://github.com/${GITHUB_USER}/${PN}/archive/${GITHUB_TAG}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="lto"

# TODO: unbundle some stuff (there may be nested dependencies):
#	* V8: ARANGO FORK https://github.com/arangodb-helper/v8
#		“[We need] all locales (known as full-icu, ~25 MB icudt*.dat)”
#	* cmake: “custom boost locator”?
#	* boost-1.71.0: CANDIDATE dev-libs/boost-1.72.0 is in Gentoo
#	* date: “Forward port of C++20 date/time class”
#	* fakeit-?, fakeit-gtest-?: https://github.com/eranpeer/FakeIt
#	* fuerte: ARANGO https://github.com/arangodb/fuerte
#	* function2-?: https://github.com/Naios/function2.git
#	* iresearch-?, iresearch.build-?: https://github.com/iresearch-toolkit/iresearch
#		“ICU is used from V8”
#	* jemalloc-5.2.1: CANDIDATE dev-libs/jemalloc-5.2.1 is in Gentoo
#	* json-schema-validation: ARANGO?
#	* linenoise-ng: ARANGO FORK https://github.com/arangodb/linenoise-ng
#	* llhttp-?: https://github.com/nodejs/llhttp
#	* lz4-1.9.1: CANDIDATE app-arch/lz4-1.9.2 is in Gentoo
#	* nghttp2-?: CANDIDATE net-libs/nghttp2-1.40.0 is in Gentoo
#	* rocksdb-6.2.?: ARANGO FORK/MODIFIED? https://github.com/arangodb-helper/rocksdb, https://github.com/facebook/rocksdb/
#		“`./thirdparty.inc` [is] adjusted to use the snappy we specify. This can be adjusted by commenting out the section that sets Snappy-related CMake variables: …”
#	* swagger-ui: ARANGO MODIFIED https://github.com/swagger-api/swagger-ui
#		“Our copy of swagger-ui resides at js/assets/swagger. The index.html contains a few tweaks to make swagger-ui work with the web interface.”
#	* s2geometry-?: https://github.com/google/s2geometry
#	* snappy-1.1.7: CANDIDATE app-arch/snappy-1.1.7|8 is in Gentoo
#		“We change the target snappy to snapy-dyn so cmake doesn't interfere targets with the static library (that we need)”
#	* snowball-2.0.0: CANDIDATE dev-libs/snowball-stemmer-0.20140325 is in Gentoo
#		“stemming for IResearch. We use the latest provided cmake which we maintain.”
#	* taocpp-json-?: https://github.com/taocpp/json
#	* velocypack: ARANGO https://github.com/arangodb/velocypack
#	* zlib-1.2.11: CANDIDATE sys-libs/zlib-1.2.11 is in Gentoo
# Also see https://github.com/arangodb/arangodb/blob/3.7.0/3rdParty/README_maintainers.md

# In config stage, we see
#	* Performing Test CMAKE_HAVE_LIBC_PTHREAD - Failed
#	* Looking for pthread_create in pthreads - not found
#	* Looking for pthread_create in pthread - found
#	* backtrace facility detected in default set of libraries
#	* The following features have been disabled:
#		- GFLAGS, allows changing command line flags.
#		- GLOG, provides logging configurability.
#		- SHARED_LIBS, builds shared libraries instead of static.
#	* Found SWIG: /usr/bin/swig (found version "3.0.12")
#	* Could NOT find PythonLibs (missing: PYTHON_INCLUDE_DIRS)
#	* Could NOT find BFD (missing:  BFD_INCLUDE_DIR BFD_SHARED_LIBS…
#	* Found Perl: /usr/bin/perl (found version "5.30.1")
#	* Could NOT find Unwind (missing:  Unwind_INCLUDE_DIR Unwind_SHARED_LIBS…
#	* LZMA shared library not found. Required if during linking the following errors are seen:…
#	* Found Git: /usr/bin/git (found version "2.26.2")

RDEPEND="
	>=dev-libs/openssl-1.1.1f[-bindist]
	${PYTHON_DEPEND}
"
DEPEND="
	${RDEPEND}
"
# gcc-8 needed for (complete) C++17 support # TODO: consider clang option
BDEPEND="
	${PYTHON_DEPEND}
	>=sys-devel/gcc-8
"

pkg_setup() {
	check-reqs_pkg_setup
	if [[ ${MERGE_TYPE} != 'binary' ]] ; then
		[[ $(gcc-major-version) -ge 8 ]] || die "GCC 8 or newer must be used to build arangodb"
		# TODO: consider clang option
	fi
	python-any-r1_pkg_setup
	ebegin "Ensuring arangodb user and group exist"
	enewgroup arangodb
	enewuser arangodb -1 -1 -1 arangodb
	eend $?
}

src_prepare() {
	cmake-utils_src_prepare
}

CMAKE_BUILD_TYPE=Release

src_configure() {
	# TODO: Python include dir fix actually kills the build
	# TODO: make sure /etc and /var are used instead of /usr/etc and /usr/var
	local mycmakeargs=(
		-DVERBOSE=on
		-DUSE_OPTIMIZE_FOR_ARCHITECTURE=on
#		-DPYTHON_INCLUDE_DIR=$(python_get_includedir)
		-DUSE_GOOGLE_TESTS=off # TODO: is this needed?
		-DCMAKE_INSTALL_PREFIX:PATH=/
#		-DCMAKE_INSTALL_SYSCONFIG=/etc
#		-DCMAKE_INSTALL_LOCALSTATEDIR=/var
		-DCMAKE_SKIP_RPATH:BOOL=on
		-DUSE_IPO=$(usex lto) # disables resource-hungry LTO
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

# TODO: see
# * https://github.com/gbevan/portage-arangodb-overlay/blob/master/dev-db/arangodb3/files/arangodb3.initd
# * https://github.com/arangodb/arangodb/tree/3.7.0/Installation
# * https://gitweb.gentoo.org/repo/gentoo.git/tree/net-ftp/proftpd/files/proftpd.initd
#
	#newinitd "${FILESDIR}"/arangodb3.initd arangodb

	systemd_newunit Installation/systemd/arangodb3.service.in arangodb3.service
}
