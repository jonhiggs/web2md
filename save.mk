SHELL = /bin/bash

save: TITLE = $(shell cat tmp/data.json | jq -r .title)
save: DATE = $(shell gdate +%Y%m%d)
save: SLUG = $(shell echo ${TITLE} | tr '[:upper:]' '[:lower:]' |tr '-' ' ' | tr -d '[:punct:]' | tr '[:blank:]' '-')
save: OUTPUT_DIR = ${HOME}/Dropbox/web_archive/${DATE}-${SLUG}/
save:
	mkdir -p ${OUTPUT_DIR}
	cp /tmp/data.md ${OUTPUT_DIR}
	cp -aux /tmp/assets/ ${OUTPUT_DIR}
