SHELL = /bin/bash
include ./secrets.mk
MERCURY_API_KEY ?= XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

ifndef URL
  $(error URL is undefined)
endif

.PRECIOUS: tmp/data.json
tmp/data.json:
	mkdir -p $(dir $@)
	curl                                                    \
		-H "x-api-key: ${MERCURY_API_KEY}"                  \
		"https://mercury.postlight.com/parser?url=${URL}"   \
		> $@

tmp/data.html: tmp/data.json
	$(MAKE) -f html.mk $@

tmp/data.md: tmp/data.html assets
	pandoc --wrap=none -w markdown_strict $< -o $@

assets: tmp/data.json tmp/data.html
	$(MAKE) -f asset.mk all

.PHONY: save
save: TITLE = $(shell jq -r .title tmp/data.json)
save: DATE = $(shell gdate +%Y%m%d)
save: SLUG = $(shell echo "${TITLE}" | tr '[:upper:]' '[:lower:]' | tr '-' ' ' | tr -d '[:punct:]' | tr '[:blank:]' '-')
save: OUTPUT_DIR = ${HOME}/Dropbox/articles
save: tmp/data.md assets
	cp $< ${OUTPUT_DIR}/${DATE}-${SLUG}.md
	cp -r tmp/assets/ ${OUTPUT_DIR}/assets/

preview: tmp/data.md assets
	marked $<

clean:
	rm -Rf tmp/*
