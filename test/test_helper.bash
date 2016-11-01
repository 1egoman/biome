#!/bin/bash

# run before each test
function setup {
	BIOME="$(pwd)/biome.sh"
	TEST_ROOT="$(pwd)/test"
	clean_test
}

# reset the test state
function clean_test {
	cd $TEST_ROOT
	[[ -d workspace/ ]] && rm -rf workspace/

	mkdir -p workspace/cwd
	mkdir -p workspace/home

	chmod -R 777 workspace/

	OLDHOME="$HOME"
	HOME="$(pwd)/workspace/home"
	cd workspace/cwd
}
