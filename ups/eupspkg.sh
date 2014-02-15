# EupsPkg config file. Sourced by 'eupspkg'

# Breaks on Darwin w/o this
export LANG=C

prep()
{
	# Apply standard patches
	default_prep

	# Apply the necessary patche if building with clang
	detect_compiler
	if [[ $COMPILER_TYPE == clang ]]; then
		msg "clang detected: applying clang-preprocessor-output-difference.patch"
		patch -s -p1 < ./patches/clang/clang-preprocessor-output-difference.patch
	fi
}

config()
{
	./configure --prefix="$PREFIX" --enable-thread-safe-client --enable-local-infile --with-ssl

	# Hack for clang compatibility on Linux
	detect_compiler

	if [[ $COMPILER_TYPE == clang && $(uname) == Linux ]]; then
		echo '/* LSST: clang compatibility hack */' >> include/config.h
		echo '#define HAVE_GETHOSTBYNAME_R_GLIBC2_STYLE 1' >> include/config.h
	fi
}

install()
{
	default_install

	( cd $PREFIX/lib && ln -s mysql/* . )
}
