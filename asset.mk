SHELL = /bin/bash

ifndef ASSET_URL
  $(error ASSET_URL is undefined)
endif

sha = $(shell echo ${ASSET_URL} | md5)
ext = $(shell basename "${ASSET_URL}" | sed 's/\?.*//' | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]')
file = tmp/assets/${sha}.${ext}

.PHONY: fetch
fetch: ${file}

.PHONY: sha ext file
sha ext file:
	@echo $($@)

${file}:
	mkdir -p $(dir $@)
	wget "${ASSET_URL}" -O $@
	$(MAKE) -f ./html.mk fixup_link ASSET_URL="${ASSET_URL}" FILE="$@"
