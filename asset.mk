SHELL = /bin/bash
assets-url = $(shell jq .content < tmp/data.json | grep -o "img\ src=[^>]*" | grep -o http[^\ \\]*)
assets-enc = $(shell for i in ${assets-url}; do echo $$i | base64; done)

all: %: $(addprefix fetch-,${assets-enc})

fetch-%: URL = $(shell echo $* | base64 -D)
fetch-%: SHA = $(shell echo ${URL} | md5)
fetch-%: EXT = $(shell basename "${URL}" | sed 's/\?.*//' | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]')
fetch-%:
	$(MAKE) -f asset.mk tmp/assets/${SHA}.${EXT} URL=${URL}

tmp/assets/%:
	mkdir -p tmp/assets
	wget "${URL}" -O $@
