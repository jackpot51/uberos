build/initfs.tag: initfs.toml prefix
	cd kernel && xargo clean
	rm -rf build/initfs
	mkdir -p build/initfs
	export PATH="$(PREFIX_PATH):$$PATH" && \
	cargo run --manifest-path installer/Cargo.toml --release -- $(INSTALLER_FLAGS) -c $< build/initfs/
	touch $@

build/initfs_live.tag: initfs_live.toml prefix
	cd kernel && xargo clean
	rm -rf build/initfs_live
	mkdir -p build/initfs_live
	export PATH="$(PREFIX_PATH):$$PATH" && \
	cargo run --manifest-path installer/Cargo.toml --release -- $(INSTALLER_FLAGS) -c $< build/initfs_live/
	touch $@
