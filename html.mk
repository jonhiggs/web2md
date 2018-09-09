ifeq (,$(wildcard tmp/data.json))
  $(error tmp/data.json does not exist)
endif

TITLE = $(shell cat tmp/data.json | jq -r .title)
SOURCE = $(shell cat tmp/data.json | jq -r .url)
CONTENT = $(shell cat tmp/data.json | jq -r .content)
LEAD_IMAGE = $(shell cat tmp/data.json | jq -r .lead_image_url)

tmp/data.html:
	mkdir -p $(dir $@)
	@echo "<a href='${SOURCE}'>Source</a>" > $@
	@echo "<h1>${TITLE}</h1>" >> $@
	-@[[ ${LEAD_IMAGE} != 'null' ]] && echo "<img src='${LEAD_IMAGE}' />" >> $@
	@echo '${CONTENT}' >> $@

.PHONY: fixup_link
fixup_link: pattern = $(shell echo ${ASSET_URL} | tr '\/$$?\-.[]{}' '.')
fixup_link: tmp/data.html
	sed -i .bak "s#${pattern}#${FILE}#g" $@
