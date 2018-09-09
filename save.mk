SHELL = /bin/bash

title = $(shell cat tmp/data.json | jq -r .title)
date = $(shell gdate +%Y%m%d)
slug = $(shell echo ${title} | tr '[:upper:]' '[:lower:]' |tr '-' ' ' | tr -d '[:punct:]' | tr '[:blank:]' '-')

OUTPUT_DIR ?= ${HOME}/Dropbox/web_archive/${date}-${slug}/
ASSETS_DIR = ${OUTPUT_DIR}/assets/

files = tmp/data.md
assets = $(wildcard /tmp/assets/*)

all:
	mkdir -p ${OUTPUT_DIR} ${ASSETS_DIR}
	cp ${files} ${OUTPUT_DIR}
	cp ${assets} ${ASSETS_DIR}

.PHONY: title date slug output_dir
title date slug output_dir:
	@echo $($@)
