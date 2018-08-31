SHELL = /bin/bash
include ./secrets.mk
MERCURY_API_KEY ?= XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

info:
	echo ${MERCURY_API_KEY}

.PRECIOUS: tmp/data.json
tmp/data.json:
	curl                                                    \
		-H "x-api-key: ${MERCURY_API_KEY}"                  \
		"https://mercury.postlight.com/parser?url=${URL}"   \
		> $@

tmp/data.html: TITLE = $(shell cat tmp/data.json | jq -r .title)
tmp/data.html: SOURCE = $(shell cat tmp/data.json | jq -r .url)
tmp/data.html: CONTENT = $(shell cat tmp/data.json | jq -r .content)
tmp/data.html: tmp/data.json
	@echo "<a href='${SOURCE}'>Source</a>" > $@
	@echo "<h1>${TITLE}</h1>" >> $@
	@echo '${CONTENT}' >> $@

.DELETE_ON_ERROR: tmp/data_local_assets.html
tmp/data_local_assets.html: fetch_assets
tmp/data_local_assets.html: tmp/data.html tmp/asset_list_shas.txt
	cp $< $@
	while read l; do \
		regex=$$(echo $$l | awk '{ print $$2 }'| tr '\/$$?\-.[]{}' '.');  \
		replacement="assets\/$$(echo $$l | awk '{ print $$1 }')";               \
		echo "escaped thing $$regex"; \
		sed -i .bak "s/$$regex/$$replacement/g" $@; \
	done < tmp/asset_list_shas.txt

tmp/data.md: tmp/data_local_assets.html
	pandoc --wrap=none -w markdown_strict $< -o $@

tmp/asset_list.txt: tmp/data.json
	jq .content < $< | grep -o "img\ src=[^>]*" | grep -o http[^\ \\]* > $@

.DELETE_ON_ERROR: tmp/asset_list_shas.txt
tmp/asset_list_shas.txt: tmp/asset_list.txt
	while read l; do                    \
		ext=$$(basename "$$l" | sed 's/\?.*//' | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]'); \
		echo $$l | md5 | tr -d "\n" >> $@;      \
		echo -n ".$$ext " >> $@;                \
		echo " $$l" >> $@;                      \
	done < $<
	[[ $$(tail -n 1 "$@" | wc -w) -eq 2 ]]

.PHONY: fetch_assets
fetch_assets: tmp/asset_list_shas.txt
	mkdir -p tmp/assets
	while read l; do                                       \
		o="tmp/assets/$$(echo $$l | awk '{ print $$1 }')"; \
		i=$$(echo $$l | awk '{ print $$2 }');              \
		[[ -f $$o ]] && continue;                          \
		wget "$$i" -O "$$o";                               \
	done < $<

clean:
	rm -Rf tmp/*
