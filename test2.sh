#!/usr/bin/env bash

oneTimeSetUp() {
  export URL="http://fake.com"
  make clean
  cp -r test/test2/* ./tmp
}

testDataJson() {
  assertTrue 'has tmp/data.json' "[[ -f tmp/data.json ]]"
}

testDataHtml() {
  title="Welcome to Vintage Saw's Saw Filing Treatise"
  source="<a href='http://www.vintagesaws.com/library/primer/sharp.html'>Source</a>"
  asset_url="http://www.vintagesaws.com/library/primer/fileright.JPG"
  lead_image="<img src='${asset_url}' />"
  assertTrue 'can create tmp/data.html' "make -f html.mk tmp/data.html"
  assertTrue 'has tmp/data.html' "[[ -f tmp/data.html ]]"
  assertEquals "title" "<h1>${title}</h1>" "$(grep h1 tmp/data.html)"
  assertEquals "source" "${source}" "$(grep 'Source</a>' tmp/data.html)"
  assertFalse "lead_image" "ggrep -q \"^.img src..\" ./tmp/data.html"
  assertTrue  "fixup link" "$(make -f html.mk fixup_link ASSET_URL="${asset_url}" FILE="xxxx.jpg")"
  assertTrue  "local link is in html" 'grep -q xxxx.jpg tmp/data.html'
  assertFalse "remote link is not in html" "grep -q '\'fileright.JPG' tmp/data.html"
}

testAssets() {
  export ASSET_URL="${lead_image}"
  assertEquals "asset_urls" "18" "$(make -f assets.mk asset_urls | wc -w | tr -d " ")"
}

. ./test/shunit2/shunit2
