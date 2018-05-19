PREFIX?=/usr/local
VERSION:=$(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" DIKit.xcodeproj/DIGenKit_Info.plist)
XCCONFIG_PATH=DIKit.xcconfig

build:
	swift build -c release -Xswiftc -static-stdlib

install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/dikitgen" "$(PREFIX)/bin/dikitgen"

set_version:
	agvtool new-marketing-version ${VERSION}
	sed -i '' -e 's/current = ".*"/current = "${VERSION}"/g' Sources/DIGenKit/Version.swift

generate_xcodeproj:
	swift package generate-xcodeproj --xcconfig-overrides ${XCCONFIG_PATH}
	$(MAKE) set_version VERSION=$(VERSION)
