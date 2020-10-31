.PHONY: all build repo

all: build repo

build:
	python3 build.py
	# TODO: build single packages
	for package in $$(ls -1 build | grep -v orig.tar.xz); do \
		cd build/$${package}/ ; \
		tar xf ../$${package}*.orig.tar.xz ; \
		dpkg-buildpackage -us -uc -ui ; \
		cd ../.. ; \
	done

repo:
	reprepro -b repo includedeb stable build/*.deb
