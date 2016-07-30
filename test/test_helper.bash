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
	rm -R workspace/
	mkdir workspace
	chmod 777 workspace/
	mkdir workspace/cwd
	chmod 777 workspace/cwd
	mkdir workspace/home
	chmod 777 workspace/home
	OLDHOME="$HOME"
	HOME="$(pwd)/workspace/home"
	cd workspace/cwd
}
