PROJECT := Hello Sky.xcodeproj
SCHEME  := Hello Sky
DEST    := platform=iOS Simulator,name=iPhone 17
PACKAGES := SkyCore SkyData SkyUI Globe

.PHONY: build test test-packages test-app clean

build:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination "$(DEST)" build

test: test-packages test-app

test-packages:
	@for p in $(PACKAGES); do \
		echo "==> $$p"; \
		swift test --package-path "Packages/$$p" || exit 1; \
	done

test-app: build

clean:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" clean
	@for p in $(PACKAGES); do swift package --package-path "Packages/$$p" clean; done
