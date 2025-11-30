VERSION := $(shell jq -r '.KPlugin.Version' package/metadata.json)

.SILENT:
.PHONY: dev real-test i18n-merge i18n-build pack release

dev:
	./scripts/test.sh $(COUNTRY)
real-test:
	./scripts/real-test.sh

i18n-merge:
	./scripts/translate-merge.sh
i18n-build:
	./scripts/translate-build.sh

pack:
	./scripts/package.sh
release:
	./scripts/release.sh
