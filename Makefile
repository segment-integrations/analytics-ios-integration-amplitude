SDK ?= "iphonesimulator"
DESTINATION ?= "platform=iOS Simulator,name=iPhone 7"
PROJECT := Segment-Amplitude
XC_ARGS := -scheme $(PROJECT)_Example -workspace Example/$(PROJECT).xcworkspace -sdk $(SDK) -destination $(DESTINATION) ONLY_ACTIVE_ARCH=NO

install: Example/Podfile $(PROJECT).podspec
	pod repo update
	pod install --project-directory=Example

lint:
	pod lib lint

clean:
	xcodebuild $(XC_ARGS) clean

build:
	xcodebuild $(XC_ARGS)

test:
	xcodebuild test $(XC_ARGS)

clean-pretty:
	set -o pipefail && xcodebuild $(XC_ARGS) clean | xcpretty

build-pretty:
	set -o pipefail && xcodebuild $(XC_ARGS) | xcpretty

test-pretty:
	set -o pipefail && xcodebuild test $(XC_ARGS) | xcpretty --report junit

.PHONY: install clean build test
