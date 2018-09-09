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
	$(MAKE) -f assets.mk all

save: tmp/data.md
	$(MAKE) -f save.mk all

preview: tmp/data.md assets
	marked $<

clean:
	rm -Rf tmp/*
