TERMUX_PKG_HOMEPAGE=https://github.com/Byron/gitoxide
TERMUX_PKG_DESCRIPTION="Rust implementation of Git"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE-APACHE, LICENSE-MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.33.0"
TERMUX_PKG_SRCURL=https://github.com/Byron/gitoxide/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=0fc1e0f9e36d2622f6a11925607090abf619c73551d2a8f5ea710e97ef1a9eb4
TERMUX_PKG_DEPENDS="resolv-conf"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+\.\d+\.\d+"

termux_step_pre_configure() {
	termux_setup_cmake
	termux_setup_rust

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	cargo fetch --target "${CARGO_TARGET_NAME}"

	for d in $CARGO_HOME/registry/src/*/trust-dns-resolver-*; do
		sed -e "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|" \
			$TERMUX_PKG_BUILDER_DIR/trust-dns-resolver.diff \
			| patch --silent -p1 -d ${d} || :
	done

	if [ "$TERMUX_ARCH" == "x86_64" ]; then
		RUSTFLAGS+=" -C link-arg=$($CC -print-libgcc-file-name)"
	fi
}

termux_step_make() {
	cargo build \
		--jobs $TERMUX_MAKE_PROCESSES \
		--target $CARGO_TARGET_NAME \
		--release \
		--no-default-features \
		--features max-pure
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin \
		target/${CARGO_TARGET_NAME}/release/ein \
		target/${CARGO_TARGET_NAME}/release/gix
}
