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
	-@[[ ${LEAD_IMAGE} != 'null' ]] && echo "<img src='${LEAD_IMAGE}' />" >> $@
	@echo '${CONTENT}' >> $@

tmp/data.md: tmp/data.html assets
	pandoc --wrap=none -w markdown_strict $< -o $@

assets: tmp/data.json tmp/data.html
	$(MAKE) -f asset.mk all

save: TITLE = $(shell jq -r .title tmp/data.json)
save: DATE = $(shell gdate +%Y%m%d)
save: SLUG = $(shell echo "${TITLE}" | tr '[:upper:]' '[:lower:]' | tr '-' ' ' | tr -d '[:punct:]' | tr '[:blank:]' '-')
save: OUTPUT_DIR = ${HOME}/Dropbox/articles
save: tmp/data.md assets
	mkdir -p ${OUTPUT_DIR}/assets/
	cp $< ${OUTPUT_DIR}/${DATE}-${SLUG}.md
	cp -r tmp/assets/ ${OUTPUT_DIR}/assets/

preview: tmp/data.md assets
	marked $<

clean:
	rm -Rf tmp/*
