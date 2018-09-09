SHELL = /bin/bash
export asset-urls = $(shell jq .content tmp/data.json | grep -o "img\ src=[^>]*" | grep -o http[^\ \\]*)
export asset-urls += $(filter-out null,$(shell jq -r .lead_image_url tmp/data.json))


.PHONY: fetch_all
fetch_all:
	for u in ${asset-urls}; do make -f ./asset.mk fetch ASSET_URL="$$u"; done

.PHONY: asset_urls
asset_urls:
	@echo ${asset-urls}
