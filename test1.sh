#!/usr/bin/env bash

oneTimeSetUp() {
  export URL="http://fake.com"
  make clean
  cp -r test/test1/* ./tmp
}

testDataJson() {
  assertTrue 'has tmp/data.json' "[[ -f tmp/data.json ]]"
}

testDataHtml() {
  title="<h1>Water Filter Made from a Tree Branch Removes 99% of E. coli Bacteria</h1>"
  source="<a href='https://www.energyseek.co.uk/2014/02/27/water-filter-made-tree-branch-removes-99-e-coli-bacteria/'>Source</a>"
  asset_url="https://www.energyseek.co.uk/wp-content/uploads/2014/06/xylemwaterfilter.jpg"
  lead_image="<img src='${asset_url}' />"
  assertTrue 'can create tmp/data.html' "make -f html.mk tmp/data.html"
  assertTrue 'has tmp/data.html' "[[ -f tmp/data.html ]]"
  assertEquals "title" "${title}" "$(grep h1 tmp/data.html)"
  assertEquals "source" "${source}" "$(grep Source tmp/data.html)"
  assertEquals "lead_image" "${lead_image}" "$(grep 'img src..https://www.energyseek.co.uk/wp-content/uploads/2014/06/xylemwaterfilter.jpg' ./tmp/data.html)"
  assertTrue   "fixup link" "$(make -f html.mk fixup_link ASSET_URL="${asset_url}" FILE="xxxx.jpg")"
  assertEquals "link is fixed" "<img src='assets/xxxx.jpg' />" "$(grep img.src tmp/data.html)"
}

testAssets() {
  lead_image='https://www.energyseek.co.uk/wp-content/uploads/2014/06/xylemwaterfilter.jpg'
  export ASSET_URL="${lead_image}"
  assertEquals "asset_urls" "${lead_image}" "$(make -f assets.mk asset_urls)"
}

testAsset() {
  export ASSET_URL='https://www.energyseek.co.uk/wp-content/uploads/2014/06/xylemwaterfilter.jpg'
  assertEquals "sha" "0aa76bbe75dfeceddc2a1d6b9f183349" "$(make -f asset.mk sha)"
  assertEquals "ext" "jpg" "$(make -f asset.mk ext)"
  assertEquals "file" "tmp/assets/0aa76bbe75dfeceddc2a1d6b9f183349.jpg" "$(make -f asset.mk file)"
}

testSave() {
  title="Water Filter Made from a Tree Branch Removes 99% of E. coli Bacteria"
  slug='water-filter-made-from-a-tree-branch-removes-99-of-e-coli-bacteria'
  assertEquals "title" "${title}" "$(make -f save.mk title)"
  assertEquals "slug" "${slug}" "$(make -f save.mk slug)"
}

. ./test/shunit2/shunit2
