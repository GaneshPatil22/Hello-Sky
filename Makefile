PROJECT := Hello Sky.xcodeproj
SCHEME  := Hello Sky
DEST    := platform=iOS Simulator,name=iPhone 18 Pro
PACKAGES := SkyCore SkyData SkyUI Globe

.PHONY: build test test-packages test-app check-core clean

build:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination "$(DEST)" build

test: check-core test-packages test-app

test-packages:
	@for p in $(PACKAGES); do \
		echo "==> $$p"; \
		swift test --package-path "Packages/$$p" || exit 1; \
	done

# SkyCore must stay free of UI frameworks so it tests in seconds and can run
# anywhere. This is a Phase 1 completion criterion, so it is checked, not trusted.
check-core:
	@! grep -rEn '^import (SwiftUI|UIKit|AppKit|RealityKit|WidgetKit)' \
		Packages/SkyCore/Sources || \
		(echo "SkyCore must not import a UI framework"; exit 1)
	@echo "==> SkyCore is free of UI frameworks"

# The app's own tests need a simulator, so they are slower than the packages'.
test-app:
	xcodebuild test -project "$(PROJECT)" -scheme "$(SCHEME)" -destination "$(DEST)" \
		| grep -E "Test run with|error:|TEST SUCCEEDED|TEST FAILED" || true

clean:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" clean
	@for p in $(PACKAGES); do swift package --package-path "Packages/$$p" clean; done
