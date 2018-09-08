SHELL = /bin/bash
include ./secrets.mk
MERCURY_API_KEY ?= XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

ifndef URL
  $(error URL is undefined)
endif

.PRECIOUS: tmp/data.json
tmp:
	mkdir -p $@

tmp/data.json: tmp
	curl                                                    \
		-H "x-api-key: ${MERCURY_API_KEY}"                  \
		"https://mercury.postlight.com/parser?url=${URL}"   \
		> $@

tmp/data.html: TITLE = $(shell cat tmp/data.json | jq -r .title)
tmp/data.html: SOURCE = $(shell cat tmp/data.json | jq -r .url)
tmp/data.html: CONTENT = $(shell cat tmp/data.json | jq -r .content)
tmp/data.html: LEAD_IMAGE = $(shell cat tmp/data.json | jq -r .lead_image_url)
tmp/data.html: tmp/data.json
	@echo "<a href='${SOURCE}'>Source</a>" > $@
	@echo "<h1>${TITLE}</h1>" >> $@
	@[[ -z ${LEAD_IMAGE} ]] || echo "<img src='${LEAD_IMAGE}' />" >> $@
	@echo '${CONTENT}' >> $@

tmp/data.md: tmp/data.html assets
	pandoc --wrap=none -w markdown_strict $< -o $@

assets: tmp/data.json tmp/data.html
	$(MAKE) -f asset.mk all

clean:
	rm -Rf tmp/*
