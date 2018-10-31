PREFIX?=/usr/local

install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/dikitgen" "$(PREFIX)/bin/dikitgen"

set_version:
	agvtool new-marketing-version ${VERSION}
	sed -i '' -e 's/current = ".*"/current = "${VERSION}"/g' Sources/DIGenKit/Version.swift

