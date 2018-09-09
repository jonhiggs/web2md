SHELL = /bin/bash

title = $(shell cat tmp/data.json | jq -r .title | tr -d "'\"")
date = $(shell gdate +%Y%m%d)
slug = $(shell echo ${title} | tr '[:upper:]' '[:lower:]' |tr '-' ' ' | tr -d '[:punct:]' | tr '[:blank:]' '-')

OUTPUT_DIR ?= ${HOME}/Dropbox/articles/${date}-${slug}
ASSETS_DIR = ${OUTPUT_DIR}/assets

doc_file = ${OUTPUT_DIR}/doc.md

files = tmp/data.md
assets = $(wildcard tmp/assets/*)

all:
	mkdir -p ${OUTPUT_DIR} ${ASSETS_DIR}
	cp tmp/data.md ${doc_file}
	cp ${assets} ${ASSETS_DIR}

.PHONY: title date slug output_dir doc_file
title date slug output_dir doc_file:
	@echo $($@)
